# Extremely simple app-of-apps, only passing revision down to children

function(targetRevision="HEAD") [
  std.parseYaml(importstr './manifests/base-app.yaml')
  + {spec+: {source+: { targetRevision: targetRevision}}},

  # Quick and dirty patch to make the team-b app from team-a
  std.parseYaml(importstr './manifests/base-app.yaml')
  + {
    metadata+: {
      name: "team-b",
    },
    spec+: {
      source+: {
        targetRevision: targetRevision,
        path: "./stream-teams/team-b",
      },
    },
  },
]
