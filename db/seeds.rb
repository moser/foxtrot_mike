mosr = Person.create(:firstname => 'martin', :lastname => 'mosr')
acc = Account.create(:login => 'moser', :password => '123456', :password_confirmation => '123456')
acc.person = mosr
acc.save
