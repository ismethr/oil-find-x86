import { releases } from './releases';

export type Language = 'zh' | 'en';

export interface HomeItem {
  icon: string;
  name: string;
  path: string;
  meta: string;
  meta2?: string;
  act: { href?: string; scroll?: string; fill?: string };
}

interface LandingCopy {
  title: string;
  description: string;
  placeholder: string;
  sort: string;
  dl: string;
  downloadNote: string;
  toastDemo: string;
  noneTitle: string;
  noneBody: string;
  folder: string;
  app: string;
  'nav.speed': string;
  'nav.syntax': string;
  'nav.github': string;
  'nav.download': string;
  'nav.lang': string;
  'speed.h': string;
  'speed.sub': string;
  'speed.frame': string;
  'stat.scan': string;
  'stat.mem': string;
  'stat.live': string;
  'speed.fine': string;
  'syn.h': string;
  'syn.sub': string;
  'source.h': string;
  'source.sub': string;
  'source.download': string;
  'source.github': string;
  'note.open.h': string;
  'note.open': string;
  'note.opensource.h': string;
  'note.opensource': string;
  'note.fda.h': string;
  'note.fda': string;
  'note.privacy.h': string;
  'note.privacy': string;
  'legal.github': string;
  'legal.download': string;
  lead: string[];
  chips: string[];
  hints: [string, string][];
  syntax: [string, string, string][];
  home: HomeItem[];
  statusHome: (n: number) => string;
  statusDemo: (n: number) => string;
  statusReplay: (hits: string, ms: string) => string;
  items: (n: string | number) => string;
  today: (time: string) => string;
  yesterday: (time: string) => string;
  date: (month: number, day: number) => string;
  bytes: (n: string) => string;
}

export const GITHUB_URL = 'https://github.com/oil-oil/oil-find';

export const dict: Record<Language, LandingCopy> = {
  zh: {
    title: 'Oil Find：不到 10 毫秒，找到 Mac 上的任何文件',
    description: '按 ⇧⌘F，屏幕正中弹出搜索框。85 万个文件，每敲一个键不到 10 毫秒出结果。支持拼音、通配符和实时更新。免费开源。',
    'nav.speed': '速度', 'nav.syntax': '语法', 'nav.github': 'GitHub', 'nav.download': '下载', 'nav.lang': 'EN',
    lead: ['不到 10 毫秒，', '找到 Mac 上的任何文件'],
    placeholder: '在这里试试：wd、png、readme',
    sort: '相关度 ⇅',
    dl: '下载 macOS 版',
    downloadNote: '免费开源。macOS 14 及以上，Apple 芯片',
    'speed.h': '每个键，都在一帧之内',
    'speed.sub': '连续输入 readme。索引里有 851,420 个文件，下面是每个键的实测耗时。',
    'speed.frame': '一帧 16.7 ms',
    'stat.scan': '第一次扫完 85 万个文件', 'stat.mem': '常驻内存', 'stat.live': '文件新建、改名、删除后出现在结果里',
    'speed.fine': '数据来自一台 Apple 芯片的 Mac，默认索引范围。连续输入时只在上一次的结果里收窄，所以越敲越快。',
    'syn.h': '想找得更准，就多写一点',
    'syn.sub': '点一行，把它填进上面的搜索框。',
    'source.h': '开源，免费',
    'source.sub': 'MIT 许可证。代码、问题反馈和新版本都在 GitHub 上。',
    'source.download': '下载 macOS 版',
    'source.github': '在 GitHub 上查看',
    'note.open.h': '第一次打开', 'note.open': '应用还没有经过苹果公证。双击后如果被拦下，去「系统设置 → 隐私与安全性」，在底部点「仍要打开」。只需要一次。',
    'note.opensource.h': '开源', 'note.opensource': '代码在 GitHub 上，MIT 许可证。欢迎提问题和改进。',
    'note.fda.h': '完全磁盘访问', 'note.fda': '可选。不开也能用，只是搜不到邮件和其他应用的数据。',
    'note.privacy.h': '隐私', 'note.privacy': '只索引文件名，不读文件内容。索引只存在这台 Mac 上。每天检查一次，只读取版本信息。',
    'legal.github': 'GitHub', 'legal.download': '下载 macOS 版',
    chips: ['全部', '文件夹', '应用', '文档', '图片', '代码'],
    hints: [['↩', '打开'], ['↑↓', '选择'], ['Tab', '切换筛选']],
    statusHome: n => `从这里开始 · ${n} 项`,
    statusDemo: n => `演示数据 · 共 ${n} 项`,
    statusReplay: (hits, ms) => `实测 · 共 ${hits} 项 · ${ms} ms`,
    toastDemo: '这里是演示 · 装上之后按 ↩ 直接打开文件',
    noneTitle: '没有匹配的结果',
    noneBody: '这里只有十几个演示文件。装上之后，搜的是你自己的 Mac。',
    items: n => `${n} 项`,
    today: t => `今天 ${t}`, yesterday: t => `昨天 ${t}`, date: (m, d) => `${m}月${d}日`,
    folder: '文件夹', app: '应用', bytes: n => `${n} 字节`,
    home: [
      { icon: 'download', name: '下载 Oil Find', path: '免费开源。macOS 14 及以上，Apple 芯片', meta: releases[0].version, meta2: '1.5 MB', act: { href: '/downloads/Oil-Find.zip' } },
      { icon: 'timer', name: '每敲一个键，不到 10 毫秒', path: '85 万个文件，连续输入时只在上一次的结果里收窄', meta: '速度', act: { scroll: 'speed' } },
      { icon: 'pinyin', name: '拼音也能搜', path: '输入 <code>wd</code> 找到「文档」，输入 <code>xmwd</code> 找到「项目文档」', meta: '中文', act: { fill: 'wd' } },
      { icon: 'live', name: '文件一改，结果就变', path: '新建、改名、移动、删除，一秒内生效。关机期间的变动开机后自动补齐', meta: '实时', act: { scroll: 'speed' } },
      { icon: 'lock', name: '只看文件名', path: '不读文件内容，索引只存在这台 Mac 上', meta: '隐私', act: { scroll: 'notes' } },
      { icon: 'syntax', name: '查询语法', path: '<code>*.pdf</code>　<code>ext:png</code>　<code>!node_modules</code>　<code>dm:today</code>　<code>~/Desktop/</code>', meta: '进阶', act: { scroll: 'syntax' } },
      { icon: 'file', name: '开源', path: 'MIT 许可证，代码在 GitHub 上', meta: 'GitHub', act: { href: GITHUB_URL } },
    ],
    syntax: [
      ['wd', '拼音首字母，找到「文档」', '拼音'],
      ['readme !node_modules', '包含 readme，排除 node_modules 里的', '排除'],
      ['*.png', '通配符，匹配整个名称', '通配'],
      ['~/Desktop/ png', '只在桌面下面找', '路径'],
      ['dm:today ext:md', '今天改过的 Markdown', '时间'],
    ],
  },
  en: {
    title: 'Oil Find: any file on your Mac in under 10 ms',
    description: 'Press ⇧⌘F and a search field appears at the center of your screen. 850,000 files, under 10 ms per keystroke. Pinyin, wildcards and live updates. Free and open source.',
    'nav.speed': 'Speed', 'nav.syntax': 'Syntax', 'nav.github': 'GitHub', 'nav.download': 'Download', 'nav.lang': '中文',
    lead: ['Any file on your Mac, ', 'in under 10 ms'],
    placeholder: 'Try it here: wd, png, readme',
    sort: 'Relevance ⇅',
    dl: 'Download for macOS',
    downloadNote: 'Free and open source. macOS 14 or later, Apple silicon',
    'speed.h': 'Every keystroke lands within one frame',
    'speed.sub': 'Typing readme against an index of 851,420 files. Measured time for each key.',
    'speed.frame': 'one frame, 16.7 ms',
    'stat.scan': 'to scan 850,000 files the first time', 'stat.mem': 'of memory while running', 'stat.live': 'until a new, renamed or deleted file shows up',
    'speed.fine': 'Measured on an Apple silicon Mac with the default index scope. Each new letter only narrows the previous result, so it gets faster as you type.',
    'syn.h': 'Write a little more to find exactly that',
    'syn.sub': 'Click a row to try it in the search field above.',
    'source.h': 'Open source and free',
    'source.sub': 'MIT licensed. Code, issues and releases all live on GitHub.',
    'source.download': 'Download for macOS',
    'source.github': 'View on GitHub',
    'note.open.h': 'Opening it the first time', 'note.open': 'The app isn’t notarized by Apple yet. If macOS blocks it, go to System Settings → Privacy & Security and click “Open Anyway” at the bottom. Once is enough.',
    'note.opensource.h': 'Open source', 'note.opensource': 'The code is on GitHub under the MIT license. Issues and pull requests are welcome.',
    'note.fda.h': 'Full Disk Access', 'note.fda': 'Optional. Without it, Mail and other apps’ data can’t be searched.',
    'note.privacy.h': 'Privacy', 'note.privacy': 'File names only, never file contents. The index stays on this Mac. Checks once a day and only reads version info.',
    'legal.github': 'GitHub', 'legal.download': 'Download for macOS',
    chips: ['All', 'Folders', 'Apps', 'Documents', 'Images', 'Code'],
    hints: [['↩', 'Open'], ['↑↓', 'Select'], ['Tab', 'Switch filter']],
    statusHome: n => `Start here · ${n} items`,
    statusDemo: n => `Demo data · ${n} ${n === 1 ? 'item' : 'items'}`,
    statusReplay: (hits, ms) => `Measured · ${hits} items · ${ms} ms`,
    toastDemo: 'This is a demo · once installed, ↩ opens the file',
    noneTitle: 'No results',
    noneBody: 'There are only a few demo files here. Once installed, it searches your own Mac.',
    items: n => `${n} items`,
    today: t => `Today ${t}`, yesterday: t => `Yesterday ${t}`,
    date: (m, d) => `${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1]} ${d}`,
    folder: 'Folder', app: 'App', bytes: n => `${n} bytes`,
    home: [
      { icon: 'download', name: 'Download Oil Find', path: 'Free and open source. macOS 14 or later, Apple silicon', meta: releases[0].version, meta2: '1.5 MB', act: { href: '/downloads/Oil-Find.zip' } },
      { icon: 'timer', name: 'Under 10 ms per keystroke', path: '850,000 files. Each new letter only narrows the previous result', meta: 'Speed', act: { scroll: 'speed' } },
      { icon: 'pinyin', name: 'Pinyin search', path: 'Type <code>wd</code> to find 文档, <code>xmwd</code> to find 项目文档', meta: 'Chinese', act: { fill: 'wd' } },
      { icon: 'live', name: 'Results follow your files', path: 'Create, rename, move, delete: reflected within a second, even after a restart', meta: 'Live', act: { scroll: 'speed' } },
      { icon: 'lock', name: 'File names only', path: 'Never reads file contents. The index stays on this Mac', meta: 'Privacy', act: { scroll: 'notes' } },
      { icon: 'syntax', name: 'Query syntax', path: '<code>*.pdf</code>　<code>ext:png</code>　<code>!node_modules</code>　<code>dm:today</code>　<code>~/Desktop/</code>', meta: 'Advanced', act: { scroll: 'syntax' } },
      { icon: 'file', name: 'Open source', path: 'MIT licensed. The code is on GitHub', meta: 'GitHub', act: { href: GITHUB_URL } },
    ],
    syntax: [
      ['wd', 'Pinyin initials, finds 文档', 'Pinyin'],
      ['readme !node_modules', 'Contains readme, not inside node_modules', 'Exclude'],
      ['*.png', 'Wildcard, matches the whole name', 'Wildcard'],
      ['~/Desktop/ png', 'Only under the Desktop', 'Path'],
      ['dm:today ext:md', 'Markdown files changed today', 'Date'],
    ],
  },
};

export type SitePage = 'home' | 'changelog';
export function pagePath(lang: Language, page: SitePage = 'home'): string {
  const prefix = lang === 'en' ? '/en' : '';
  return page === 'home' ? prefix || '/' : prefix + '/changelog';
}

export const commonCopy = {
  brand: 'Oil Find',
  copyright: '© 2026 Oil Find',
  shortcutLabel: 'Shift Command F',
  searchLabel: 'Search',
  ogDescription: '不到 10 毫秒，找到 Mac 上的任何文件。',
  stats: [['3.3', 's', 'stat.scan'], ['45', 'MB', 'stat.mem'], ['< 1', 's', 'stat.live']],
} as const;
