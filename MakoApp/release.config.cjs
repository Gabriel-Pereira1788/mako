const rules = [
  { type: 'feat', release: 'minor', title: '✨ Features' },
  { type: 'fix', release: 'patch', title: '🐛 Bug Fixes' },
  { type: 'perf', release: 'patch', title: '💨 Performance' },
  { type: 'refactor', release: 'patch', title: '🔄 Refactors' },
  { type: 'docs', release: 'patch', title: '📚 Documentation' },
  { type: 'chore', release: 'patch', title: '🛠️ Other changes' },
]

const sortMap = Object.fromEntries(
  rules.map((rule, index) => [rule.title, index])
)

/**
 * @type {import('semantic-release').GlobalConfig}
 */
module.exports = {
  branches: ['main'],
  tagFormat: 'makoapp-v${version}',
  plugins: [
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'conventionalcommits',
        releaseRules: [
          { breaking: true, release: 'major' },
          { revert: true, release: 'patch' },
        ].concat(rules.map(({ type, release }) => ({ type, release }))),
      },
    ],
    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'conventionalcommits',
        presetConfig: {
          types: rules.map(({ type, title }) => ({
            type,
            section: title,
          })),
        },
        writerOpts: {
          commitGroupsSort: (a, z) => sortMap[a.title] - sortMap[z.title],
        },
      },
    ],
    [
      '@semantic-release/github',
      {
        assets: [
          { path: '../Mako-*.dmg', label: 'Mako macOS App' },
        ],
      },
    ],
  ],
}
