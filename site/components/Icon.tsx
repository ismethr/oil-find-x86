import { ICONS } from '@/content/icons';

export function Icon({ name, className, empty = false }: { name: string; className?: string; empty?: boolean }) {
  return <svg className={className} viewBox={empty ? '0 0 34 34' : '0 0 32 32'} aria-hidden="true" dangerouslySetInnerHTML={{ __html: ICONS[name] ?? ICONS.file }} />;
}
