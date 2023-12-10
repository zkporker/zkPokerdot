## 基本资料

项目名称：zkPokerdot

项目立项日期：2023年11月

## 项目整体简介

- 简介：zkPokerdot是一条为“公平游戏”而生的波卡平行链。对于游戏而言，公平是一种确保良好玩家体验，激发真实竞争，构建健康社区，以及实现商业成功的重要保障。zkPokerdot通过应用ZK（零知识证明）技术，为部署在链上的游戏提供了公平性和透明度的机制。
- 技术路线：zkPokerdot采用了 Substrate 框架，创建了用于游戏的逻辑电路，以及基于pallet实现的ZK验证器。游戏参与者可以利用前端页面进行ZK证明，并提交交易到链上完成游戏。尤其对于“信息不对称”游戏（即非公开化的、玩家无法获取彼此信息的游戏，典型的有扑克/卡牌对战游戏），zkPokerdot依靠其独特的证明和验证系统，提供了极佳的公平性和透明度，有效地保护了所有玩家的利益。

其他更多开发中信息请见[详细设计说明](./docs/archive.md)

## 技术架构

TODO

## 本项目的起点

TODO

## 黑客松期间计划完成的事项

**接口：合约 \<-\> 前端**

- [ ] 启动游戏 `fn create_game(name: String, pub_key: String) -> uint`
- [ ] 登记公钥 `fn join_game(id: uint, pub_key: String)`
- [ ] 提交洗牌数据 `fn shuffle(id: uint, cards: uint[])`
- [ ] 传递解密信息 `fn unmask(id: uint, unmask: uint[])`
- [ ] 登记叫地主 `fn call(id: uint, pub_key: String)`
- [ ] 提交出牌数据 `fn play(id: uint, pub_key: String, cards: uint[])`

_说明：涉及密码学信息传递部分还需要再斟酌一下，可能会有改变_

**功能：节点+合约**

- [ ] 节点基础框架
- [ ] 随机源选取
- [ ] 出牌规则验证
- [ ] 集成ZK验证

**功能：前端**

- [ ] 基础扑克牌界面
- [ ] 开始/加入游戏交互
- [ ] 发牌交互
- [ ] 叫地主界面交互
- [ ] 出牌界面交互
- [ ] 胜利界面交互

**功能：密码学**

- [ ] 可验证秘密洗牌机制说明
- [ ] 洗牌ZK证明生成
- [ ] 出牌ZK证明生成
- [ ] 私牌解密
- [ ] 公牌解密
- [ ] ZK验证器


## 队员信息

- [Icer](https://github.com/wizicer) - Full-Stack Developer
- [Hiya](https://github.com/lovehiya) - Product Owner
- [Wenjin](https://github.com/wenjin1997) - Cryptographic Developer
- [Panchen](https://github.com/panchen451161722) - Frontend Developer
- [mambaCoder](https://github.com/mambaCoder) - Backend Developer