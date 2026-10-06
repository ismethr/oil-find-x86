/** @type {import('next').NextConfig} */
const config = {
  async redirects() {
    return [
      { source: '/activated', destination: '/', permanent: true },
      { source: '/recover', destination: '/', permanent: true },
      { source: '/en/activated', destination: '/en', permanent: true },
      { source: '/en/recover', destination: '/en', permanent: true },
    ];
  },
  async headers() {
    return [
      { source: '/downloads/:path*', headers: [{ key: 'Cache-Control', value: 'public, max-age=300' }] },
      { source: '/updates/latest.json', headers: [{ key: 'Cache-Control', value: 'no-cache' }] },
    ];
  },
};
export default config;
