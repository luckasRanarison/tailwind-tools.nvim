<script>
  let items = [1, 2, 3];
</script>

<div class="bg-neutral-700">
  <div class="font-semibold text-blue-400">Test</div>
  <ul>
    {#each items as item}
      <li class="text-white">{item}</li>
    {/each}
  </ul>
</div>
