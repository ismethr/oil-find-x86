'use client';

import { useEffect, useRef } from 'react';
import { commonCopy, dict, type Language } from '@/content/dict';
import { RUN } from '@/content/demo';
import styles from './SpeedTrace.module.css';
import shared from './Landing.module.css';

export function SpeedTrace({ lang }: { lang: Language }) {
  const trace = useRef<HTMLDivElement>(null), t = dict[lang];
  useEffect(() => {
    const element = trace.current!, media = matchMedia('(prefers-reduced-motion: reduce)');
    let observer: IntersectionObserver | undefined;
    const show = () => { element.classList.add(styles.in); observer?.disconnect(); };
    const change = () => { if (media.matches) show(); };
    if ('IntersectionObserver' in window && !media.matches) {
      observer = new IntersectionObserver(entries => { if (entries[0].isIntersecting) show(); }, { threshold: .5 });
      observer.observe(element);
    } else show();
    media.addEventListener('change', change);
    return () => { observer?.disconnect(); media.removeEventListener('change', change); };
  }, []);
  return <section className="col sect" id="speed">
    <h2>{t['speed.h']}</h2><p className="sub">{t['speed.sub']}</p>
    <div className={`sheet ${styles.trace}`} ref={trace} id="trace">
      <div className={styles.axis}><span /><span><span>0</span><span>{t['speed.frame']}</span></span><span /></div>
      {RUN.map(([text, hits, ms], index) => <div className={styles.trow} key={text}>
        <code>{text.slice(0, -1)}<b>{text.slice(-1)}</b></code><div className={styles.track}><div className={styles.fill} style={{ width: `${(Number(ms) / 16.7 * 100).toFixed(1)}%`, transitionDelay: `${index * 60}ms` }} /></div>
        <span className={styles.ms}>{ms} ms</span><span className={styles.hits}>{t.items(hits)}</span>
      </div>)}
    </div>
    <div className={styles.stats}>{commonCopy.stats.map(([value, unit, key]) => <div key={key}><b>{value}<small>{unit}</small></b><span>{t[key]}</span></div>)}</div>
    <p className={shared.fine}>{t['speed.fine']}</p>
  </section>;
}
