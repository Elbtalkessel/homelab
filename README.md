# Homelab infrastructure

```
           ┌──────────┐
           │  Router  │
           └─────┬────┘
  ┌──────────────┴────────────────────┐
  │ ┌─────────────┐   ┌─────────────┐ │
  │ │    DNS      │───│   Clients   │ │
  │ └────┬────────┘   └─────────────┘ │
  │ ┌────┴──────────────────────────┐ │
  │ │ Home Server                   │ │
  │ │ ┌────────────┐  ┌────────────┐│ │
  │ │ │ Traefik    │  │ Service    ││ │
  │ │ └────────────┘  └────────────┘│ │
  │ └───────┬───────────────────────┘ │
  └─────────┴─────────────────────────┘
            │
     ┌──────┴─────┐
     │ Tor Client │
     └─────┬──────┘
       ┌───┴────┐
       │Clearnet│
       └────────┘
```

## [Traefik](https://doc.traefik.io)

Proxies requests to a docker service, handles SSL termination and acts as
a certificate authority with help of [step-ca](https://smallstep.com/docs/step-ca/).

## [Service](https://docs.docker.com/compose/)
