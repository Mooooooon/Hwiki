import { event_types, eventSource } from '@sillytavern/script';
import { extension_settings } from '@sillytavern/scripts/extensions';

const FALLBACK_BAR_CLASS = 'hwiki--qr--bar';
const QUICK_REPLY_BAR_ID = 'qr--bar';
const QUICK_REPLY_BUTTONS_CLASS = 'qr--buttons';
const QUICK_REPLY_COMBINED_TOGGLE = '#qr--isCombined';
const QUICK_REPLY_COMBINED_EVENT_NAMESPACE = '.hwikiQuickReplyCombined';

const APP_READY_EVENTS = [event_types.APP_READY, 'chatLoaded', event_types.SETTINGS_UPDATED];

function findQuickReplyBars($send_form: JQuery<HTMLElement>): JQuery<HTMLElement> {
  return $send_form.find('div').filter(function () {
    return this.id === QUICK_REPLY_BAR_ID;
  });
}

function recalculateElement($send_form: JQuery<HTMLElement>): HTMLElement | null {
  if ($send_form.length === 0) {
    return null;
  }

  let $quick_reply_bars = findQuickReplyBars($send_form);
  const $external_bars = $quick_reply_bars.filter(function () {
    return !$(this).hasClass(FALLBACK_BAR_CLASS);
  });

  let $quick_reply_bar: JQuery<HTMLElement>;
  if ($external_bars.length > 0) {
    $quick_reply_bars.filter(`.${FALLBACK_BAR_CLASS}`).remove();
    $quick_reply_bar = $external_bars.first();
  } else if ($quick_reply_bars.length > 0) {
    $quick_reply_bar = $quick_reply_bars.first();
    $quick_reply_bars = $quick_reply_bars.slice(1);
    $quick_reply_bars.remove();
  } else {
    $quick_reply_bar = $(
      `<div id="${QUICK_REPLY_BAR_ID}" class="${FALLBACK_BAR_CLASS} flex-container flexGap5">`,
    ).prependTo($send_form);
  }

  if (_.get(extension_settings, 'quickReplyV2.isCombined')) {
    const $possible_button_containers = $quick_reply_bar.children(`.${QUICK_REPLY_BUTTONS_CLASS}`);
    const $button_container =
      $possible_button_containers.length > 0
        ? $possible_button_containers.first()
        : $(`<div class="${QUICK_REPLY_BUTTONS_CLASS}">`).appendTo($quick_reply_bar);
    return $button_container[0];
  }

  return $quick_reply_bar[0];
}

function mutationTouchesQuickReply(mutation: MutationRecord): boolean {
  if (mutation.type !== 'childList') {
    return false;
  }

  const changed_nodes = [...mutation.addedNodes, ...mutation.removedNodes].filter(
    (node): node is Element => node.nodeType === Node.ELEMENT_NODE,
  );

  return changed_nodes.some(element => {
    return (
      element.id === QUICK_REPLY_BAR_ID ||
      element.classList.contains('qr--button') ||
      element.classList.contains(QUICK_REPLY_BUTTONS_CLASS) ||
      element.querySelector(`#${QUICK_REPLY_BAR_ID}, .qr--button, .${QUICK_REPLY_BUTTONS_CLASS}`) !== null
    );
  });
}

/**
 * 获取与酒馆助手脚本按钮相同的 Quick Reply 按钮挂载位置。
 *
 * 酒馆助手没有向插件公开注册按钮的接口，因此这里仅复用它的 DOM 布局约定，
 * 并在 Quick Reply 重建按钮栏时自动迁移 Teleport 目标。
 */
export function useButtonDestinationElement(): Readonly<Ref<HTMLElement | null>> {
  const element = shallowRef<HTMLElement | null>(null);
  const $send_form = $('#send_form');

  const recalculate = () => {
    element.value = recalculateElement($send_form);
  };

  recalculate();

  for (const event of APP_READY_EVENTS) {
    eventSource.on(event, recalculate);
  }

  $(document)
    .off(`change${QUICK_REPLY_COMBINED_EVENT_NAMESPACE}`, QUICK_REPLY_COMBINED_TOGGLE)
    .on(`change${QUICK_REPLY_COMBINED_EVENT_NAMESPACE}`, QUICK_REPLY_COMBINED_TOGGLE, recalculate);

  const observer =
    $send_form[0] === undefined
      ? null
      : new MutationObserver(mutations => {
          if (mutations.some(mutationTouchesQuickReply)) {
            recalculate();
          }
        });

  observer?.observe($send_form[0], { childList: true, subtree: true });

  onScopeDispose(() => {
    observer?.disconnect();
    for (const event of APP_READY_EVENTS) {
      eventSource.removeListener(event, recalculate);
    }
    $(document).off(`change${QUICK_REPLY_COMBINED_EVENT_NAMESPACE}`, QUICK_REPLY_COMBINED_TOGGLE);
  });

  return element;
}
