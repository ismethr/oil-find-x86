export function isShortcut(event: KeyboardEvent): boolean {
  return event.metaKey && event.shiftKey && !event.altKey && !event.ctrlKey && event.key.toLowerCase() === 'f';
}
