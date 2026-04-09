package com.h5app.app;

import android.os.Bundle;

import com.getcapacitor.BridgeActivity;
import com.getcapacitor.CapConfig;

import java.io.IOException;
import java.net.ServerSocket;

import fi.iki.elonen.NanoHTTPD;
import okhttp3.OkHttpClient;

public class MainActivity extends BridgeActivity {

  private LocalWebServer localServer;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    int port = resolvePort(BuildConfig.LOCAL_PROXY_PORT);

    OkHttpClient client = new OkHttpClient.Builder().build();
    localServer = new LocalWebServer(getApplicationContext(), port, client);
    try {
      localServer.start(NanoHTTPD.SOCKET_READ_TIMEOUT, false);
    } catch (IOException e) {
      throw new RuntimeException("Start local server failed", e);
    }

    // 告诉 Capacitor 用本机 URL 作为 appUrl（这样 WebView 会加载 http://127.0.0.1:<port>/）
    this.config = new CapConfig.Builder(this)
      .setServerUrl("http://127.0.0.1:" + port)
      .create();

    super.onCreate(savedInstanceState);
  }

  @Override
  public void onDestroy() {
    if (localServer != null) {
      localServer.stop();
      localServer = null;
    }
    super.onDestroy();
  }

  private static int findFreePort() {
    try (ServerSocket socket = new ServerSocket(0)) {
      return socket.getLocalPort();
    } catch (IOException e) {
      return 52143;
    }
  }

  private static int resolvePort(int preferredPort) {
    if (preferredPort <= 0) {
      return findFreePort();
    }

    try (ServerSocket ignored = new ServerSocket(preferredPort)) {
      return preferredPort;
    } catch (IOException e) {
      // 配置端口被占用时，自动回退随机端口，避免启动失败
      return findFreePort();
    }
  }
}
