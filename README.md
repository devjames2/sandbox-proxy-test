# proxy test

to run this project

```bash
npm install
npx hardhat test
```

## Test summary

### upgrade 전의 token id 와 upgrade 후의 id 를 비교할 수 있다.

1. MyCollectible 을 deployProxy 로 deploy
   1. mint 후의 token id 는 1
2. MyCollectibleV2 를 upgradeProxy 로 deploy
   1. mint 후의 token id 는 2

---

### upgrade 하지 않고 그냥 deployProxy 한다면??

1. upgrade 가 아니고 그냥 deployProxy 로 해도 storage 는 proxy 에 있으므로 기존 token id 가 남아 있어야 한다.
2. test 해보니 그러함.

---

### proxy pattern 을 사용하지 않고 contract 를 upgrade 하려 한다면??

1. 기존에 발급된 token id 는 모두 없어진다고 봐야 한다. (기존 contract 에는 당연히 남아 있음)
2. test 해보니 그러함.