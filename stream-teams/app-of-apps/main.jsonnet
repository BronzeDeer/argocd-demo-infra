# Extremely simple app-of-apps, only passing revision down to children

function(targetRevision="HEAD") [
  std.parseYaml(importstr './manifests/base-app.yaml')
  + {spec+: {source+: { targetRevision: targetRevision}}},

]
