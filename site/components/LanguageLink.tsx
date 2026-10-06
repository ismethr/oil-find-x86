'use client';

import { useEffect, useState } from 'react';
import { dict, pagePath, type Language, type SitePage } from '@/content/dict';

export function LanguageLink({ lang, page }: { lang: Language; page: SitePage }) {
  const target = pagePath(lang === 'zh' ? 'en' : 'zh', page);
  const [href, setHref] = useState(target);
  useEffect(() => {
    const current = new URLSearchParams(location.search), retained = new URLSearchParams();
    for (const key of ['q']) {
      const value = current.get(key);
      if (value !== null) retained.set(key, value);
    }
    setHref(target + (retained.size ? `?${retained}` : '') + location.hash);
  }, [target]);
  return <a className="nav" id="lang" href={href}>{dict[lang]['nav.lang']}</a>;
}
