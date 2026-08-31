<template>
  <div id="hwiki-prompt-buttons" class="qr--buttons">
    <button
      ref="trigger_element"
      type="button"
      class="qr--button menu_button interactable"
      aria-haspopup="menu"
      :aria-expanded="is_menu_open"
      aria-controls="hwiki-prompt-menu"
      @click.stop.prevent="toggle_menu"
      @pointerdown.stop
    >
      {{ t`Hwiki 测试` }}
    </button>

    <Teleport to="body">
      <div
        v-if="is_menu_open"
        id="hwiki-prompt-menu"
        ref="menu_element"
        class="hwiki-prompt-menu list-group"
        role="menu"
        :aria-label="t`选择情景`"
        @click.stop
        @pointerdown.stop
      >
        <Transition name="hwiki-menu-level" mode="out-in" @after-enter="handle_menu_level_entered">
          <div v-if="selected_group === null" key="root" class="hwiki-prompt-menu__level">
            <div class="hwiki-prompt-menu__title">{{ t`选择情景` }}</div>
            <button
              v-for="group in prompt_groups"
              :key="group.id"
              type="button"
              class="hwiki-prompt-menu__item list-group-item"
              role="menuitem"
              @click="enter_group(group)"
            >
              <span>{{ translate(group.label) }}</span>
              <i class="fa-solid fa-chevron-right" aria-hidden="true"></i>
            </button>
          </div>

          <div v-else-if="selected_section === null" :key="selected_group.id" class="hwiki-prompt-menu__level">
            <button
              type="button"
              class="hwiki-prompt-menu__item hwiki-prompt-menu__back list-group-item"
              role="menuitem"
              @click="return_to_root"
            >
              <i class="fa-solid fa-arrow-left" aria-hidden="true"></i>
              <span>{{ t`返回` }}</span>
            </button>
            <div class="hwiki-prompt-menu__title">{{ translate(selected_group.label) }}</div>
            <button
              v-for="section in selected_group.sections"
              :key="section.id"
              type="button"
              class="hwiki-prompt-menu__item list-group-item"
              role="menuitem"
              @click="enter_section(section)"
            >
              <span>{{ translate(section.label) }}</span>
              <i class="fa-solid fa-chevron-right" aria-hidden="true"></i>
            </button>
          </div>

          <div v-else :key="selected_section.id" class="hwiki-prompt-menu__level">
            <button
              type="button"
              class="hwiki-prompt-menu__item hwiki-prompt-menu__back list-group-item"
              role="menuitem"
              @click="return_to_group"
            >
              <i class="fa-solid fa-arrow-left" aria-hidden="true"></i>
              <span>{{ t`返回` }}</span>
            </button>
            <div class="hwiki-prompt-menu__title">{{ translate(selected_section.label) }}</div>
            <button
              v-for="item in selected_section.children"
              :key="item.id"
              type="button"
              class="hwiki-prompt-menu__item list-group-item"
              role="menuitem"
              @click="select_prompt(item.prompt)"
            >
              <span>{{ translate(item.label) }}</span>
            </button>
          </div>
        </Transition>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { prompt_groups, PromptMenuGroup, PromptMenuSection } from '@/data/promptMenu';
import { translate } from '@sillytavern/scripts/i18n';

const trigger_element = useTemplateRef<HTMLButtonElement>('trigger_element');
const menu_element = useTemplateRef<HTMLDivElement>('menu_element');
const is_menu_open = ref(false);
const selected_group = ref<PromptMenuGroup | null>(null);
const selected_section = ref<PromptMenuSection | null>(null);

let popper_instance: ReturnType<typeof Popper.createPopper> | null = null;

function focus_first_menu_item() {
  menu_element.value?.querySelector<HTMLButtonElement>('[role="menuitem"]')?.focus();
}

async function create_menu_popper() {
  await nextTick();
  if (trigger_element.value === null || menu_element.value === null) {
    return;
  }

  popper_instance?.destroy();
  popper_instance = Popper.createPopper(trigger_element.value, menu_element.value, {
    placement: 'top-start',
    strategy: 'fixed',
    modifiers: [
      { name: 'offset', options: { offset: [0, 8] } },
      { name: 'flip', options: { fallbackPlacements: ['bottom-start', 'top-end', 'bottom-end'] } },
      { name: 'preventOverflow', options: { padding: 8 } },
    ],
  });
  await popper_instance.update();
  focus_first_menu_item();
}

function open_menu() {
  selected_group.value = null;
  selected_section.value = null;
  is_menu_open.value = true;
}

function close_menu() {
  is_menu_open.value = false;
  selected_group.value = null;
  selected_section.value = null;
  popper_instance?.destroy();
  popper_instance = null;
}

function toggle_menu() {
  if (is_menu_open.value) {
    close_menu();
  } else {
    open_menu();
  }
}

function handle_menu_level_entered() {
  void popper_instance?.update();
  focus_first_menu_item();
}

function enter_group(group: PromptMenuGroup) {
  selected_group.value = group;
  selected_section.value = null;
}

function return_to_root() {
  selected_group.value = null;
  selected_section.value = null;
}

function enter_section(section: PromptMenuSection) {
  selected_section.value = section;
}

function return_to_group() {
  selected_section.value = null;
}

function append_to_input(text: string) {
  const textarea = document.querySelector<HTMLTextAreaElement>('#send_textarea');
  if (textarea === null) {
    console.warn('[Hwiki] 未找到 SillyTavern 输入框 #send_textarea');
    return;
  }

  const separator = textarea.value.length > 0 && !textarea.value.endsWith('\n') ? '\n' : '';
  textarea.value += `${separator}${text}`;
  textarea.dispatchEvent(new Event('input', { bubbles: true }));
  textarea.focus();
  textarea.setSelectionRange(textarea.value.length, textarea.value.length);
}

function select_prompt(prompt: string) {
  close_menu();
  append_to_input(prompt);
}

watch(is_menu_open, open => {
  if (open) {
    void create_menu_popper();
  }
});

useEventListener(document, 'pointerdown', event => {
  if (!is_menu_open.value || !(event.target instanceof Node)) {
    return;
  }
  if (trigger_element.value?.contains(event.target) || menu_element.value?.contains(event.target)) {
    return;
  }
  close_menu();
});

useEventListener(document, 'keydown', event => {
  if (is_menu_open.value && event.key === 'Escape') {
    event.preventDefault();
    close_menu();
    trigger_element.value?.focus();
  }
});

onBeforeUnmount(() => {
  popper_instance?.destroy();
});
</script>

<style scoped>
.hwiki-prompt-menu {
  z-index: 30000;
  box-sizing: border-box;
  min-width: 200px;
  max-width: min(300px, calc(100vw - 16px));
  max-height: min(360px, 60vh);
  padding: 4px;
  overflow-x: hidden;
  overflow-y: auto;
  color: var(--SmartThemeBodyColor);
  background-color: var(--SmartThemeBlurTintColor);
  backdrop-filter: blur(calc(var(--SmartThemeBlurStrength) * 2));
}

#hwiki-prompt-buttons > button {
  touch-action: manipulation;
}

.hwiki-prompt-menu__level {
  display: flex;
  flex-direction: column;
  width: 100%;
}

.hwiki-prompt-menu__title {
  padding: 6px 10px;
  overflow: hidden;
  font-weight: 700;
  text-overflow: ellipsis;
  white-space: nowrap;
  opacity: 0.8;
}

.list-group .hwiki-prompt-menu__item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-sizing: border-box;
  width: 100%;
  min-height: 40px;
  padding: 8px 10px;
  color: var(--SmartThemeBodyColor);
  font: inherit;
  text-align: left;
  background: transparent;
  border: 0;
  border-radius: 6px;
  opacity: 0.8;
}

.list-group .hwiki-prompt-menu__item:hover,
.list-group .hwiki-prompt-menu__item:focus-visible {
  background-color: var(--white20a);
  outline: 1px solid var(--SmartThemeBorderColor);
  opacity: 1;
}

.list-group .hwiki-prompt-menu__back {
  justify-content: flex-start;
  gap: 8px;
  border-bottom: 1px solid var(--SmartThemeBorderColor);
  border-radius: 6px 6px 0 0;
}

.hwiki-menu-level-enter-active,
.hwiki-menu-level-leave-active {
  transition:
    opacity 120ms ease,
    transform 120ms ease;
}

.hwiki-menu-level-enter-from {
  opacity: 0;
  transform: translateX(8px);
}

.hwiki-menu-level-leave-to {
  opacity: 0;
  transform: translateX(-8px);
}

@media (prefers-reduced-motion: reduce) {
  .hwiki-menu-level-enter-active,
  .hwiki-menu-level-leave-active {
    transition: none;
  }
}

@media screen and (max-width: 1000px) {
  .hwiki-prompt-menu {
    /* SillyTavern 的移动端会给 html 添加 transform，fixed 会以零高度的 html 为定位容器。 */
    position: absolute !important;
    inset: auto 8px calc(72px + env(safe-area-inset-bottom)) 8px !important;
    width: auto;
    max-width: none;
    transform: none !important;
  }

  .list-group .hwiki-prompt-menu__item {
    min-height: 44px;
  }
}
</style>
