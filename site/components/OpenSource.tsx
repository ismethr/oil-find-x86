import { GITHUB_URL, dict, type Language } from '@/content/dict';
import styles from './OpenSource.module.css';

export function OpenSource({ lang }: { lang: Language }) {
  const t = dict[lang];
  return <section className={`col sect ${styles.section}`} id="open-source">
    <h2>{t['source.h']}</h2>
    <p className="sub">{t['source.sub']}</p>
    <div className={styles.actions}>
      <a className="btn dark big" href="/downloads/Oil-Find.zip">{t['source.download']}</a>
      <a className="btn soft big" href={GITHUB_URL}>{t['source.github']}</a>
    </div>
  </section>;
}
