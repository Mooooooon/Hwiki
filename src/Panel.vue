<template>
  <div class="example-extension-settings">
    <div class="inline-drawer">
      <div class="inline-drawer-toggle inline-drawer-header">
        <b>{{ t`插件示例` }}</b>
        <div class="inline-drawer-icon fa-solid fa-circle-chevron-down down"></div>
      </div>
      <div class="inline-drawer-content">
        <div class="example-extension_block flex-container">
          <input class="menu_button" type="submit" :value="t`示例按钮`" @click="handle_button_click" />
        </div>

        <div class="example-extension_block flex-container">
          <input v-model="settings.button_selected" type="checkbox" />
          <label for="example_setting">{{ t`示例开关` }}</label>
        </div>

        <hr class="sysHR" />
      </div>
    </div>
<<<<<<< HEAD

    <Teleport v-if="button_destination" defer :to="button_destination">
      <PromptBar />
    </Teleport>
=======
>>>>>>> e000f17401bc15121c7e98e8b74f8f69bb0ff16c
  </div>
</template>

<script setup lang="ts">
<<<<<<< HEAD
import PromptBar from '@/PromptBar.vue';
import { useButtonDestinationElement } from '@/panel/composable/useButtonDestinationElement';
=======
>>>>>>> e000f17401bc15121c7e98e8b74f8f69bb0ff16c
import { useSettingsStore } from '@/store/settings';
import { storeToRefs } from 'pinia';

const { settings } = storeToRefs(useSettingsStore());
<<<<<<< HEAD
const button_destination = useButtonDestinationElement();
=======
>>>>>>> e000f17401bc15121c7e98e8b74f8f69bb0ff16c

const handle_button_click = () => {
  toastr.success('你好呀!');
};
</script>

<style scoped></style>
