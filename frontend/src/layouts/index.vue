<!-- 主布局入口 -->
 <template>
  <div class="common-layout">
    <el-container style="min-height: 100vh">
      <el-header style="
          display: flex;
          align-items: center;
          border-bottom: 1px solid #ddd;
          background-color: #fff;
        ">
        <Navbar />
      </el-header>
      <el-container>
        <el-aside width="220px">
          <Sidebar />
        </el-aside>
        <el-main>
            <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
    import Sidebar from '@/layouts/components/Sidebar.vue'
    import Navbar from '@/layouts/components/Navbar.vue'
</script>