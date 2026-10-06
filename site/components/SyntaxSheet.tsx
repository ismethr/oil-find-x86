'use client';

import { dict, type Language } from '@/content/dict';
import { useSearchActions } from './SearchContext';
import styles from './SyntaxSheet.module.css';

export function SyntaxSheet({ lang }: { lang: Language }) {
  const t = dict[lang], { fill } = useSearchActions();
  return <section className="col sect" id="syntax"><h2>{t['syn.h']}</h2><p className="sub">{t['syn.sub']}</p><div className={`sheet ${styles.syn}`} id="syn">
    {t.syntax.map(([query, text, tag]) => <button type="button" data-q={query} key={query} onClick={() => fill(query)}><code>{query}</code><span>{text}</span><i>{tag}</i></button>)}
  </div></section>;
}
