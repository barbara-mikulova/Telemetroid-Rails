Admin.create!([
  {user_id: 1, feed_id: 1},
  {user_id: 1, feed_id: 2}
])
Device.create!([
  {identifier: "123", name: "testovacie zariadenie", password: "HAgzOTMcf6MIf1UibWQgNJrNb4A=", comment: nil, public: false, user_id: 2},
  {identifier: "1234", name: "druhe testovacie zariadenie", password: "IBRYreJ0oY/BIm8Ck73q24Ujjm8=", comment: nil, public: true, user_id: 1},
  {identifier: "1235", name: "testovacie", password: "7t+LvIeQm+sNzlQAVAEIDW7nmjE=", comment: nil, public: false, user_id: 1},
  {identifier: "352816054311082", name: "tablet", password: "9SIYdCb0aKaOT5+kWy9ODdHRuQo=", comment: nil, public: false, user_id: 1}
])
Feed.create!([
  {name: "1feed", comment: nil, public: true, identifier: "wO4gwNRcUtQNSiSLia26QrGtwjI=", read_key: "rNBOF_93HELCRv_Zo9PHbcLB6QQ", write_key: "EKtZrSOzihrdU01RrLq_KBt1JHU"},
  {name: "2. feed", comment: "", public: true, identifier: "O_3Jt-B522nnA6ySStrBxlQ5YwY", read_key: "Rl2-fmT7Lk_W_t3vmih7ii4c-sY", write_key: "eP9wbfJEcnwAgUCdg72afIZQ4cM"}
])
Reader.create!([
  {user_id: 1, feed_id: 1},
  {user_id: 1, feed_id: 2}
])
User.create!([
  {username: "pixel", password: "asdasd", mail: "m.r@gmail.com", name: nil, comment: nil, public_email: false},
  {username: "druhy", password: "asdasd", mail: "druhy@gmail.com", name: "Sudruh Druhy", comment: nil, public_email: false},
  {username: "treti", password: "asdasd", mail: "treti@gmail.com", name: nil, comment: nil, public_email: true}
])
Writer.create!([
  {user_id: 1, feed_id: 1},
  {user_id: 1, feed_id: 2}
])
