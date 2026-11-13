<!-- 导航栏 -->
 <template>
  <div class="navbar">
    <img src="@/assets/images/libary.png" alt="logo">

    <div style="margin-left: 10px;">
        <h5>智能实验室预约系统</h5>
    </div>

    <div class="navbar-user">
        <img class="avatar" alt="头像" src="@/assets/images/libary.png">
        <div>管理员</div>
    </div>
  </div>
</template>

<script setup lang="ts">
</script>

<style scoped>
.navbar {
    height: 100%;
    padding: 0;
    flex: 1; 
    display: flex; 
    align-items: center; 
    font-size: 24px; 
    font-weight: bold;
}
.navbar img {
    margin-right: 10px;
    width: 40px;
}
.navbar-user { 
    margin-left: auto;          /* 核心：吃掉左侧剩余空间，把整块推到右 */
    display: flex;
    align-items: center;
    gap: 10px;                  /* 头像与文字之间间距，替代原来无间距 */
    font-size: 14px;            /* 右侧文字通常不需要 24px */
    font-weight: normal;
}
.avatar {
    width: 30px; 
    border-radius: 50%;
}


</style>