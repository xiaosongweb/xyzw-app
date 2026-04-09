import { CapacitorConfig } from '@capacitor/cli';
import dotenv from 'dotenv';

// 从项目根目录 .env 加载构建期配置（本地文件不提交）
dotenv.config();

const env = process.env;

// 构建期动态配置：通过环境变量覆盖；不传则使用默认值（保持当前行为不变）
const APP_ID = (env.APP_ID || 'com.h5app.app').trim();
const APP_NAME = (env.APP_NAME || '怂团').trim();
const WEB_DIR = (env.WEB_DIR || 'dist').trim();

const config: CapacitorConfig = {
  appId: APP_ID,
  appName: APP_NAME,
  webDir: WEB_DIR,
  server: {
    androidScheme: 'http',
    iosScheme: 'http'
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      launchAutoHide: true,
      backgroundColor: "#667eea",
      androidSplashResourceName: "splash",
      androidScaleType: "CENTER_CROP",
      showSpinner: false,
      iosSpinnerStyle: "small",
      spinnerColor: "#999999"
    },
    StatusBar: {
      style: "dark",
      backgroundColor: "#667eea"
    }
  }
};

export default config;

