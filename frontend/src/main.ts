import { createApp } from 'vue'
import App from './App.vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
// import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import '@/assets/css/global.css'
import router from '@/router/router'

// 创建Vue应用实例
const app =createApp(App);
// 注册路由
app.use(router);
// 注册ElementPlus组件
app.use(ElementPlus, {
  locale: zhCn,
});
// 注册ElementPlus图标组件
// for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
//   app.component(key, component)
// };
// 挂载应用实例到DOM元素
app.mount('#app');
