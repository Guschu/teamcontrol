# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

email = Rails.application.secrets.admin_email
password = Rails.application.secrets.admin_password
admin = User.create! email:email, password:password, password_confirmation:password
puts "Admin #{email} mit Passwort #{password} angelegt"
