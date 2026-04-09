package com.h5app.app;

import android.content.Context;
import android.content.res.AssetManager;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import fi.iki.elonen.NanoHTTPD;
import okhttp3.Headers;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;

/**
 * Local-only HTTP server:
 * - Serves static files from assets/public/ over http://127.0.0.1:<port>/
 * - Proxies specific /api/* routes to remote targets via OkHttp
 */
public final class LocalWebServer extends NanoHTTPD {
  private static final String ASSETS_ROOT = "public";

  private final Context appContext;
  private final OkHttpClient client;

  public LocalWebServer(Context context, int port, OkHttpClient client) {
    super("127.0.0.1", port);
    this.appContext = context.getApplicationContext();
    this.client = client;
  }

  @Override
  public Response serve(IHTTPSession session) {
    final String uri = session.getUri() == null ? "/" : session.getUri();

    if (uri.startsWith("/api/")) {
      return proxyByRule(session);
    }

    return serveStatic(session);
  }

  private Response serveStatic(IHTTPSession session) {
    String uri = session.getUri() == null ? "/" : session.getUri();
    if ("/".equals(uri)) uri = "/index.html";

    String decoded = safeDecodePath(uri);
    if (decoded == null) {
      return newFixedLengthResponse(Response.Status.BAD_REQUEST, "text/plain; charset=utf-8", "Bad path");
    }

    String assetPath = ASSETS_ROOT + decoded;
    Response r = tryServeAsset(assetPath);
    if (r != null) return r;

    // SPA fallback: if it's not a file request, return index.html
    if (!decoded.contains(".")) {
      Response idx = tryServeAsset(ASSETS_ROOT + "/index.html");
      if (idx != null) return idx;
    }

    return newFixedLengthResponse(Response.Status.NOT_FOUND, "text/plain; charset=utf-8", "Not Found");
  }

  private static final class ProxyRule {
    final String prefix;
    final String targetBase;
    final Map<String, String> headers;

    ProxyRule(String prefix, String targetBase, Map<String, String> headers) {
      this.prefix = prefix;
      this.targetBase = trimTrailingSlash(targetBase);
      this.headers = headers == null ? Collections.emptyMap() : headers;
    }

    String rewritePath(String originalPath) {
      // mimic: path.replace(/^\/api\/xxx/, "")
      if (originalPath == null) return "";
      if (originalPath.startsWith(prefix)) {
        String out = originalPath.substring(prefix.length());
        return out.isEmpty() ? "/" : out;
      }
      return null;
    }
  }

  private static Map<String, String> mapOf(String... kv) {
    Map<String, String> m = new HashMap<>();
    for (int i = 0; i + 1 < kv.length; i += 2) {
      m.put(kv[i], kv[i + 1]);
    }
    return m;
  }

  // ---- 按你提供的 devServer proxy 规则固化 ----
  private static final String UA_WEIXIN =
    "Mozilla/5.0 (Linux; Android 7.0; Mi-4c Build/NRD90M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/53.0.2785.49 Mobile MQQBrowser/6.2 TBS/043632 Safari/537.36 MicroMessenger/6.6.1.1220(0x26060135) NetType/WIFI Language/zh_CN";

  private static final ProxyRule RULE_WEIXIN = new ProxyRule(
    "/api/weixin",
    "https://open.weixin.qq.com",
    mapOf(
      "User-Agent", UA_WEIXIN,
      "Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "Referer", "https://open.weixin.qq.com/"
    )
  );

  private static final ProxyRule RULE_WEIXIN_LONG = new ProxyRule(
    "/api/weixin-long",
    "https://long.open.weixin.qq.com",
    mapOf(
      "User-Agent", UA_WEIXIN,
      "Accept", "*/*",
      "Referer", "https://open.weixin.qq.com/"
    )
  );

  private static final ProxyRule RULE_HORTOR = new ProxyRule(
    "/api/hortor",
    "https://comb-platform.hortorgames.com",
    mapOf(
      "User-Agent", "Mozilla/5.0 (Linux; Android 12; 23117RK66C Build/V417IR; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/95.0.4638.74 Mobile Safari/537.36",
      "Accept", "*/*",
      "Host", "comb-platform.hortorgames.com",
      "Connection", "keep-alive",
      "Content-Type", "text/plain; charset=utf-8",
      "Origin", "https://open.weixin.qq.com",
      "Referer", "https://open.weixin.qq.com/"
    )
  );

  private Response proxyByRule(IHTTPSession session) {
    String uri = session.getUri() == null ? "/" : session.getUri();

    ProxyRule rule = null;
    // 注意匹配优先级：更长前缀优先
    if (uri.startsWith(RULE_WEIXIN_LONG.prefix)) rule = RULE_WEIXIN_LONG;
    else if (uri.startsWith(RULE_WEIXIN.prefix)) rule = RULE_WEIXIN;
    else if (uri.startsWith(RULE_HORTOR.prefix)) rule = RULE_HORTOR;

    if (rule == null) {
      return newFixedLengthResponse(Response.Status.NOT_FOUND, "text/plain; charset=utf-8", "No proxy rule for: " + uri);
    }

    String rewrittenPath = rule.rewritePath(uri);
    if (rewrittenPath == null) {
      return newFixedLengthResponse(Response.Status.BAD_REQUEST, "text/plain; charset=utf-8", "Bad proxy path: " + uri);
    }

    String baseUrl = rule.targetBase + rewrittenPath;
    return proxyToRemote(session, baseUrl, rule.headers);
  }

  private Response tryServeAsset(String assetPath) {
    if (assetPath.contains("..")) return null;
    AssetManager am = appContext.getAssets();
    try (InputStream is = am.open(assetPath)) {
      byte[] bytes = readAll(is);
      String mime = guessMime(assetPath);
      Response r = newFixedLengthResponse(Response.Status.OK, mime, new ByteArrayInputStream(bytes), bytes.length);
      r.addHeader("Cache-Control", "no-cache");
      return r;
    } catch (IOException e) {
      return null;
    }
  }

  private Response proxyToRemote(IHTTPSession session, String baseUrl, Map<String, String> forcedHeaders) {
    try {
      String qs = session.getQueryParameterString();
      String url = (qs == null || qs.isEmpty()) ? baseUrl : (baseUrl + "?" + qs);

      Request.Builder rb = new Request.Builder().url(url);

      // Forward request headers (filter hop-by-hop + avoid Host)
      for (Map.Entry<String, String> h : session.getHeaders().entrySet()) {
        String k = h.getKey();
        String v = h.getValue();
        if (k == null || v == null) continue;
        String lk = k.toLowerCase(Locale.US);
        if (lk.equals("host") || lk.equals("connection") || lk.equals("content-length") || lk.equals("accept-encoding")) {
          continue;
        }
        rb.addHeader(k, v);
      }

      // Apply forced headers (overwrite)
      if (forcedHeaders != null && !forcedHeaders.isEmpty()) {
        for (Map.Entry<String, String> e : forcedHeaders.entrySet()) {
          if (e.getKey() == null || e.getValue() == null) continue;
          rb.header(e.getKey(), e.getValue());
        }
      }

      Method m = session.getMethod();
      RequestBody body = null;
      if (m == Method.POST || m == Method.PUT || m == Method.PATCH || m == Method.DELETE) {
        Map<String, String> files = new HashMap<>();
        session.parseBody(files);
        String raw = files.get("postData");
        if (raw == null) raw = "";

        String ct = session.getHeaders().get("content-type");
        if (ct == null || ct.isEmpty()) ct = "application/octet-stream";
        MediaType mt = MediaType.parse(ct);
        body = RequestBody.create(raw.getBytes(StandardCharsets.UTF_8), mt);
      }

      rb.method(m.name(), body);

      try (okhttp3.Response resp = client.newCall(rb.build()).execute()) {
        byte[] respBytes = resp.body() != null ? resp.body().bytes() : new byte[0];
        String contentType = resp.header("content-type", "application/octet-stream");

        Response out = newFixedLengthResponse(Response.Status.OK, contentType, new ByteArrayInputStream(respBytes), respBytes.length);
        out.setStatus(new NanoHTTPD.Response.IStatus() {
          @Override
          public String getDescription() {
            return resp.code() + " " + (resp.message() == null ? "" : resp.message());
          }

          @Override
          public int getRequestStatus() {
            return resp.code();
          }
        });

        Headers headers = resp.headers();
        for (String name : headers.names()) {
          String ln = name.toLowerCase(Locale.US);
          if (ln.equals("content-length") || ln.equals("connection") || ln.equals("transfer-encoding") || ln.equals("content-encoding")) {
            continue;
          }
          List<String> values = headers.values(name);
          if (values == null || values.isEmpty()) continue;
          out.addHeader(name, values.get(0));
        }

        return out;
      }
    } catch (Exception e) {
      return newFixedLengthResponse(Response.Status.INTERNAL_ERROR, "text/plain; charset=utf-8", "Proxy error: " + e.getMessage());
    }
  }

  private static String safeDecodePath(String uri) {
    try {
      String decoded = URLDecoder.decode(uri, "UTF-8");
      if (!decoded.startsWith("/")) decoded = "/" + decoded;
      // normalize repeated slashes
      decoded = decoded.replaceAll("/{2,}", "/");
      return decoded;
    } catch (Exception e) {
      return null;
    }
  }

  private static byte[] readAll(InputStream is) throws IOException {
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    byte[] buf = new byte[8192];
    int n;
    while ((n = is.read(buf)) >= 0) baos.write(buf, 0, n);
    return baos.toByteArray();
  }

  private static String guessMime(String path) {
    String p = path.toLowerCase(Locale.US);
    if (p.endsWith(".html")) return "text/html; charset=utf-8";
    if (p.endsWith(".js")) return "application/javascript; charset=utf-8";
    if (p.endsWith(".css")) return "text/css; charset=utf-8";
    if (p.endsWith(".svg")) return "image/svg+xml";
    if (p.endsWith(".png")) return "image/png";
    if (p.endsWith(".jpg") || p.endsWith(".jpeg")) return "image/jpeg";
    if (p.endsWith(".webp")) return "image/webp";
    if (p.endsWith(".json")) return "application/json; charset=utf-8";
    if (p.endsWith(".woff")) return "font/woff";
    if (p.endsWith(".woff2")) return "font/woff2";
    if (p.endsWith(".ttf")) return "font/ttf";
    return "application/octet-stream";
  }

  private static String trimTrailingSlash(String s) {
    if (s == null) return "";
    String out = s.trim();
    while (out.endsWith("/")) out = out.substring(0, out.length() - 1);
    return out;
  }
}

