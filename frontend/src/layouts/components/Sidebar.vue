<!-- 侧边栏 -->
<template>
  <div class="sidebar">
    <el-menu router style="height: 100%" default-active="/manage/home">
      <el-menu-item index="/manage/home">
        <el-icon><House /></el-icon>
        <span>系统首页</span>
      </el-menu-item>
      <el-menu-item index="/manage/equipment">
        <el-icon><Setting /></el-icon>
        <span>设备列表管理</span>
      </el-menu-item>
    </el-menu>
  </div>
</template>

<script setup lang="ts">
    import {Setting, House} from '@element-plus/icons-vue'
</script>

<style scoped>
.sidebar {
  height: 100%;
}
</style>