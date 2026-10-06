import { Changelog } from '@/components/Changelog';
import { siteMetadata } from '@/lib/metadata';

export const metadata = siteMetadata('en', 'changelog');
export default function Page() { return <Changelog lang="en" />; }
