# Extremely simple app-of-apps, only passing revision down to children

function(targetRevision="HEAD") [
  std.parseYaml(importstr './argocd-rbac/app.yaml')
  + {spec+: {source+: { targetRevision: targetRevision}}},

  std.parseYaml(importstr './stream-teams/app.yaml')
  + {spec+: {source+: { targetRevision: targetRevision}}},
]
