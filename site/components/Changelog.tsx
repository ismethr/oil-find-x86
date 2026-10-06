import { type Language } from '@/content/dict';
import { changelogTitle, releases } from '@/content/releases';
import { TopBar } from './TopBar';
import { LanguageLink } from './LanguageLink';

function Note({ text }: { text: string }) {
  return text.split(/(`[^`]+`)/g).map((part, index) => part.startsWith('`') && part.endsWith('`')
    ? <code key={index}>{part.slice(1, -1)}</code> : part);
}

export function Changelog({ lang }: { lang: Language }) {
  return <>
    <TopBar lang={lang} page="changelog" />
    <main className="col changelog">
      <div className="changelog-heading"><h1>{changelogTitle[lang]}</h1><LanguageLink lang={lang} page="changelog" /></div>
      {releases.map(release => <section className="release" key={release.version}>
        <div className="release-heading"><h2>{release.version}</h2><time dateTime={release.date}>{release.date}</time></div>
        <ul>{release.notes[lang].map(note => <li key={note}><Note text={note} /></li>)}</ul>
      </section>)}
    </main>
  </>;
}
