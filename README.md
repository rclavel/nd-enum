# ND::Enum

This gem allows you to create and use enums easily and quickly in your Rails project.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add nd-enum

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install nd-enum

## Usage

- [Basic usage](#basic-usage)
- [I18n](#i18n)
- [ActiveRecord Enum](#activerecord-enum)

### Basic usage

Define your enum in an ActiveRecord model:

```ruby
class User < ApplicationRecord
  nd_enum(role: %i(user admin))
end
```

It creates a module for your enum that contains one constant per enum value. Say goodbye to [magic strings](https://en.wikipedia.org/wiki/Magic_string)!

In our example, the module is `User::Role`, and the constants are `User::Role::USER` and `User::Role::ADMIN`.

```ruby
irb(main)> User::Role::USER
=> "user"

irb(main)> User::Role::ADMIN
=> "admin"

irb(main)> User::Role.all
=> ["user", "admin"]

irb(main)> User::Role.length
=> 2

irb(main)> User::Role[1]
=> "admin"

irb(main)> User::Role[:user]
=> "user"

irb(main)> User::Role.include?('foobar')
=> false

irb(main)> User::Role.include?('user')
=> true
```

ND::Enum inheritates from [`Enumerable`](https://ruby-doc.org/core-3.1.2/Enumerable.html), so it is possible to use all `Enumerable` methods on the enum module: `each`, `map`, `find`...

### I18n

Allows to translate your enum values.
Add to your locale files:

```yaml
en:
  users: # Model.table_name
    role: # attribute
      base: # default scope
        user: User
        admin: Admin
      foobar: # custom scope
        user: The user
        admin: The admin
```

Then call `t` (or `translate`) method:

```ruby
irb(main)> User::Role.t(:user) # Or `translate` method (alias)
=> "translation missing: en.users.role.base.user"
```

Use a different scope to have several translations for a single value, depending on context:

```ruby
irb(main)> User::Role.t(:user, :foobar)
=> "translation missing: en.users.role.foobar.user"
```

### `ActiveRecord` Enum

Add a wrapper to [`ActiveRecord` Enum](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html) by specifying the `db: true` option.

```ruby
class User < ApplicationRecord
  nd_enum(role: %i(user admin), db: true)
end

# It does exactly the same thing than below, but shorter:

class User < ApplicationRecord
  nd_enum(role: %i(user admin))
  enum(role: User::Role.to_h) # Or `enum(role: { user: 'user', admin: 'admin '})`
end
```

It allows to use these methods:

```ruby
user.admin!
user.admin? # => true
user.role # => "admin"
```

And these scopes:

```ruby
User.admin
User.not_admin

User.user
User.not_user

# ...
```

Disable scope definition by setting `scopes: false` to your enum:

```ruby
class User < ApplicationRecord
  nd_enum(role: %i(user admin), db: { scopes: false })
end
```

Set the default enum:

```ruby
class User < ApplicationRecord
  nd_enum(role: %i(user admin), db: { default: :admin })
end
```

Add a `prefix` or `suffix` option when you need to define multiple enums with same values. If the passed value is true, the methods are prefixed/suffixed with the name of the enum. It is also possible to supply a custom value:

```ruby
class User < ApplicationRecord
  nd_enum(role: %i(user admin), db: { prefix: true })

  # Scopes: `User.role_admin`, `User.role_user` ...
  # Methods: `User.role_admin!`, `User.role_user!` ...

  nd_enum(role: %i(user admin), db: { suffix: true })

  # Scopes: `User.admin_role`, `User.user_role` ...
  # Methods: `User.admin_role!`, `User.user_role!` ...

  nd_enum(role: %i(user admin), db: { prefix: 'foobar' })

  # Scopes: `User.foobar_admin`, `User.foobar_user` ...
  # Methods: `User.foobar_admin!`, `User.foobar_user!` ...
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Guard is also installed: `bundle exec guard`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, run `gem bump` (or manually update the version number in `version.rb`), and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rclavel/nd-enum.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
