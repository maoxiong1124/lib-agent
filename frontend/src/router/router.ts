import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router';

const routers: Array<RouteRecordRaw> = [
  {
    path: '/',
    redirect: 'manage/home',
  },
  {
    path: '/manage',
    name: 'Manage',
    component: () => import('@/layouts/index.vue'),
    children: [
      {
        path: 'home',
        name: 'Home',
        component: () => import('@/views/home/index.vue'),
      },
      {
        path: 'equipment',
        name: 'Equipment',
        component: () => import('@/views/equipment/index.vue'),
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes: routers,
});

export default router;