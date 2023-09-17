## To update the packer arm image to include ansible

```
docker image build --build-arg BUILDKIT_INLINE_CACHE=1 --progress=plain -t packer-builder-arm-ansible:vlatest .
```

`docker compose up`