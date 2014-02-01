Admin.create!([
  {user_id: 1, feed_id: 1}
])
Device.create!([
  {identifier: "123", name: "testovacie zariadenie", password: "HAgzOTMcf6MIf1UibWQgNJrNb4A=", comment: nil, current_track: 0, public: false, user_id: 2},
  {identifier: "1234", name: "druhe testovacie zariadenie", password: "IBRYreJ0oY/BIm8Ck73q24Ujjm8=", comment: nil, current_track: 0, public: true, user_id: 1},
  {identifier: "1235", name: "testovacie", password: "7t+LvIeQm+sNzlQAVAEIDW7nmjE=", comment: nil, current_track: 0, public: false, user_id: 1}
])
Feed.create!([
  {name: "1feed", comment: nil, private: true, identifier: "wO4gwNRcUtQNSiSLia26QrGtwjI="},
])
Reader.create!([
  {user_id: 1, feed_id: 5},
  {user_id: 2, feed_id: 5},
  {user_id: 3, feed_id: 5}
])
User.create!([
  {username: "pixel", password: "asdasd", mail: "m.r@gmail.com", name: nil, comment: nil, public_email: false},
  {username: "druhy", password: "asdasd", mail: "druhy@gmail.com", name: "Sudruh Druhy", comment: nil, public_email: false},
  {username: "treti", password: "asdasd", mail: "treti@gmail.com", name: nil, comment: nil, public_email: true}
])
Writer.create!([
  {user_id: 3, feed_id: 5},
  {user_id: 2, feed_id: 5},
  {user_id: 1, feed_id: 5}
])
