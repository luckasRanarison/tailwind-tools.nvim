<template>
  <div class="bg-neutral-700">
    <div class="font-semibold text-blue-400">Test</div>
    <ul>
      <li v-for="item in items" class="text-white">{{ item }}</li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      items: [1, 2, 3],
    };
  },
};
</script>
