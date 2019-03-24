# Heimdallr

> Exactly!" said Deep Thought. "So once you do know what the question actually is, you'll know what the answer means.
>
> ― Douglas Adams, The Hitchhiker's Guide to the Galaxy

[![Dependency Status](https://gemnasium.com/badges/github.com/nater540/heimdallr.svg)](https://gemnasium.com/github.com/nater540/heimdallr)
[![CircleCI](https://circleci.com/gh/nater540/heimdallr.svg?style=svg)](https://circleci.com/gh/nater540/heimdallr)

Heimdallr is a [JWT](https://jwt.io/ "JSON Web Token") authorization gem strictly designed for Rails 5 GraphQL API projects. 

While there are a handful of other projects that provide authorization and/or JWT support, none of them fit my specific needs:
 - No built-in GUI.
 - Scope based permissions.
 - Revocable & refreshable tokens.
 - Support for both HMAC & RSA encryption.
 - And (most importantly) support for the amazing [GraphQL gem](https://github.com/rmosolgo/graphql-ruby).

Please keep in mind that this project is very much a work-in-progress, and it might not even work for some users. Feel free suggest changes and improvements!

**WARNING: Heimdallr only supports PostgreSQL 9.4 and higher!**
While it would be fairly trivial to support other RDBMS, I currently only use PostgreSQL in my office.

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Installing / Getting Started](#installing--getting-started)
- [What is a Heimdallr Application?](#what-is-a-heimdallr-application)
- [Configuration](#configuration)
  - [JWT Algorithm (`default_algorithm`)](#jwt-algorithm-default_algorithm)
    - [HMAC](#hmac)
    - [RSA](#rsa)
  - [Expiration Time (`expiration_time`)](#expiration-time-expiration_time)
  - [Expiration Leeway (`expiration_leeway`)](#expiration-leeway-expiration_leeway)
  - [Secret Key (`secret_key`)](#secret-key-secret_key)
  - [Default Scopes (`default_scopes`)](#default-scopes-default_scopes)
- [Internationalization (I18n)](#internationalization-i18n)
- [GraphQL Types](#graphql-types)
  - [Algorithm Enum (`Types::AlgorithmTypeEnum`)](#algorithm-enum-typesalgorithmtypeenum)
  - [Grant Enum (`Types::GrantTypeEnum`)](#grant-enum-typesgranttypeenum)
  - [Application Type (`Types::ApplicationType`)](#application-type-typesapplicationtype)
  - [Token Type (`Types::TokenType`)](#token-type-typestokentype)
  - [DateTime Scalar (`Types::DateTimeType`)](#datetime-scalar-typesdatetimetype)
  - [Uuid Scalar (`Types::UuidType`)](#uuid-scalar-typesuuidtype)
- [GraphQL Mutations](#graphql-mutations)
  - [Create Application (`Mutations::Applications::Create`)](#create-application-mutationsapplicationscreate)
  - [Create Token (`Mutations::Tokens::Create`)](#create-token-mutationstokenscreate)
- [Services](#services)
  - [Create Application (`Heimdallr::CreateApplication`)](#create-application-heimdallrcreateapplication)
  - [Create Token (`Heimdallr::CreateToken`)](#create-token-heimdallrcreatetoken)
  - [Decode Token (`Heimdallr::DecodeToken`)](#decode-token-heimdallrdecodetoken)
- [Development](#development)
  - [Testing](#testing)
  - [Update the README.md Table of Contents](#update-the-readmemd-table-of-contents)
  - [Update the gem documentation](#update-the-gem-documentation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installing / Getting Started

Heimdallr is cryptographically signed. To be sure the gem you install has not been tampered with, add the Heimdallr public key (if you have not already) as a trusted certificate:

```shell
gem cert --add <(curl -Ls https://raw.githubusercontent.com/nater540/heimdallr/master/certs/heimdallr.pem)
```

1) Put this in your Gemfile

```ruby
gem 'heimdallr'
```


2) Run the installation generator

```shell
rails g heimdallr:install
```

_This will install the Heimdallr initializer into `config/initializers/heimdallr.rb`._


3) Run the application migration generator

```shell
rails g heimdallr:application APPLICATION_MODEL_NAME
```

_Important: If you name your token class anything other than `token`, you will need to update the association inside the generated application model!_


4) Run the token migration generator (Should be done **after** the application generator so the table name can be found)

```shell
rails g heimdallr:token TOKEN_MODEL_NAME
```


5) Include the `Heimdallr::Authenticable` module in your `ApplicationController`

```ruby
class ApplicationController < ActionController::API
  include Heimdallr::Authenticable
end
```


6) Add `before_action :heimdallr_authorize!` inside your GraphQL controller

```ruby
class GraphqlController < ApplicationController
  before_action :heimdallr_authorize!
end
```

## What is a Heimdallr Application?

_Admittedly "Application" is not the best term that I could have used, but I digress..._

Simply put, an application is a class that may issue, renew & revoke JWT tokens with specific permissions.

For example, you have two separate applications that both access a shared API:

  - A client-facing website that can list all users, but it cannot create or delete anything.
  - An admin portal that can create, read, update & delete users.
  
For (hopefully) obvious security reasons, the client-facing website application should not be permitted to issue tokens with the `create:users` or `obliterate:users` scopes.

## Configuration

This is the default initializer that will be generated:

```ruby
Heimdallr.configure do |config|

  # The default JWT algorithm to use
  config.default_algorithm = 'HS512'

  # Token validation period (Default: 30 minutes)
  config.expiration_time = -> { 30.minutes.from_now.utc }

  # The JWT expiration leeway
  config.expiration_leeway = 30.seconds

  # The master encryption key
  config.secret_key = 'RANDOMLY-GENERATED-STRING'

  # The default scopes to include for requests without a token (Optional)
  config.default_scopes = %w[view]
end
```

### JWT Algorithm (`default_algorithm`)

You can set the default JWT algorithm that will be used with the `default_algorithm` configuration option.

#### HMAC

When you use HMAC for cryptographic signing, each application will have a unique encrypted secret value generated upon creation.

Available Algorithms:
- HS256 - HMAC using SHA-256 hash algorithm.
- HS384 - HMAC using SHA-384 hash algorithm.
- HS512 - HMAC using SHA-512 hash algorithm.

You may retrieve the secret value from the application by doing the following:

```ruby
application.secret
```

#### RSA

When you use RSA for cryptographic signing, each application will have a unique encrypted certificate generated upon creation.

Available Algorithms:
- RS256 - RSA using SHA-256 hash algorithm.
- RS384 - RSA using SHA-384 hash algorithm.
- RS512 - RSA using SHA-512 hash algorithm.

You may retrieve the certificate object from the application by doing the following:

```ruby
application.rsa
```

### Expiration Time (`expiration_time`)

You can set the default JWT expiration time by setting a proc to the `expiration_time` configuration option.

```ruby
config.expiration_time = -> { 30.minutes.from_now.utc }
```

**Please keep in mind that all times must be in UTC!**

### Expiration Leeway (`expiration_leeway`)

The expiration leeway configuration option is used to account for clock skew.

### Secret Key (`secret_key`)

This is the master secret key used for encryption of application secrets \& certificates. 

**-= DANGER, WILL ROBINSON! =-**

Although a secret key is generated when you run the installation generator, it is strictly done to speed up integration time.
The secret key value should **NEVER** be stored under source control!

Instead, use an environment variable like so:

```ruby
config.secret_key = ENV.fetch(:heimdallr_key)
```

### Default Scopes (`default_scopes`)

If you provide an array of default scopes, requests that do not have an `Authorization` header will have a new token created automatically.

However, if you do not provide any default scopes requests that do not have an `Authorization` header will be rejected with the following error:

```json
{
  "errors": [
    {
      "status": "401",
      "source": {
        "pointer": "/request/headers/authorization"
      },
      "title": "Unauthorized",
      "detail": "Missing Authorization header."
    }
  ]
}
```

**Note:** You must provide a default scope if you plan to use the built-in GraphQL mutations for issuing tokens! 

## Internationalization (I18n)

Heimdallr supports I18n using the [Rails Internationalization (I18n) API](http://guides.rubyonrails.org/i18n.html "I18n API"). See `config/locales/en.yml` for further information.

## GraphQL Types

Heimdallr includes a few handy GraphQL types that can be installed into your project by running the following generator:

```shell
rails g heimdallr:types
```

### Algorithm Enum (`Types::AlgorithmTypeEnum`)

This type provides an enum with the following values:

| Name        | Description                               |
| ----------- | ----------------------------------------- |
| `HS256`     | HMAC using SHA-256 hash algorithm.        |
| `HS384`     | HMAC using SHA-384 hash algorithm.        |
| `HS512`     | HMAC using SHA-512 hash algorithm.        |
| `RS256`     | RSA using SHA-256 hash algorithm.         |
| `RS384`     | RSA using SHA-384 hash algorithm.         |
| `RS512`     | RSA using SHA-512 hash algorithm.         |

### Grant Enum (`Types::GrantTypeEnum`)

This type provides an enum with (_currently_) a single value of `SECRET`. It is used by the a few GraphQL mutations.

### Application Type (`Types::ApplicationType`)

This type is used to expose JWT applications via the API and is entirely optional (_However, it is used for mutations_). It provides the following fields:

| Name      | Type        | Description                                                                             |
| --------- | ----------- | --------------------------------------------------------------------------------------- |
| `id`      | `UuidType`  | A UUID-4 value that is set automatically by the database upon creation.                 |
| `name`    | `String`    | Provided when creating a new application, should be a human friendly value.             |
| `ip`      | `String`    | Token issue requests must come from this IP address, or they will be refused (Optional) |
| `key`     | `String`    | A randomly generated string that must be provided when issuing new tokens.              |
| `scopes`  | `Array`     | An array of scopes that this application is authorized to issue tokens for.             |

### Token Type (`Types::TokenType`)

This type is used to expose JWT tokens via the API, it provides the following fields:

| Name          | Type              | Description                                                                             |
| ------------- | ----------------- | --------------------------------------------------------------------------------------- |
| `id`          | `UuidType`        | A UUID-4 value that is set automatically by the database upon creation.                 |
| `ip`          | `String`          | The IP address this token was issued to.                                                |
| `scopes`      | `Array`           | An array of scopes that this token is granted to use.                                   |
| `application` | `ApplicationType` | The application that issued this token.                                                 |
| `jwt`         | `String`          | The encoded JWT token string.                                                           |
| `createdAt`   | `DateTime`        | An ISO-8601 encoded UTC date string representing when this token was issued.            |
| `expiresAt`   | `DateTime`        | An ISO-8601 encoded UTC date string representing when this token will expire.           |
| `revokedAt`   | `DateTime`        | An ISO-8601 encoded UTC date string representing when this was revoked.                 |
| `notBefore`   | `DateTime`        | An ISO-8601 encoded UTC date string representing when this token becomes active.        |

### DateTime Scalar (`Types::DateTimeType`)

An ISO-8601 encoded UTC date string.

### Uuid Scalar (`Types::UuidType`)

A universally unique identifier (UUID) is a 128-bit number used to identify information in computer systems.

## GraphQL Mutations

Heimdallr includes a number of GraphQL mutations that can be installed into your project by running the following generator:

```shell
rails g heimdallr:mutations
```

### Create Application (`Mutations::Applications::Create`)

This mutation lets you make new JWT applications via a GraphQL request, it has the following input fields:

| Name        | Type            | Required  | Description                                                                       |
| ----------- | --------------- | --------- | --------------------------------------------------------------------------------- |
| `name`      | `String`        | Yes       | The application name.                                                             |
| `scopes`    | `Array`         | Yes       | An array of scopes that this application will be authorized to issue tokens for.  |
| `algorithm` | `AlgorithmEnum` | Yes       | The algorithm to use for cryptographic signing tokens.                            |

**Example**

```graphql
{
  createApplication(input: {
    name: "Unicorns & Rainbows",
    scopes: ["unicorn:create", "unicorn:update", "unicorn:hug", "unicorn:ride", "rainbow:create", "rainbow:obliterate"],
    algorithm: RS256
  }) {
    application {
      id
      name
      key
    }
  }
}
```

### Create Token (`Mutations::Tokens::Create`)

This mutation lets you issue JWT tokens via a GraphQL request, it has the following input fields:

| Name          | Type                | Required  | Description                                                                                                         |
| ------------- | ------------------- | --------- | ------------------------------------------------------------------------------------------------------------------- |
| `application` | `ApplicationInput`  | Yes       | An input type that has two fields, `id` (the application UUID) and `key` (the application key)                      |
| `audience`    | `String`            | No        | Optional audience string value.                                                                                     |
| `subject`     | `String`            | No        | Optional subject string value.                                                                                      |
| `scopes`      | `Array`             | Yes       | An array of scopes that this token should be issued. (_The application must be authorized to issue these scopes!_)  |

**Example**

```graphql
{
  createToken(input: {
    application: {
      id: "6cc8b666-aa57-4933-8899-0205c9eeeb7c",
      key: "7c5b4002adb254df96c8a40fe98863f39f2a32324ac26bcd5de27a5dc4e76a22ec9616cd7f074d56e64f4d589e2b82e31c5f6995a454a5ec3d387a6342520234"
    },
    scopes: ["unicorn:hug", "unicorn:ride", "rainbow:create"],
    subject: "Supercalifragilisticexpialidocious"
  }) {
    token {
      jwt
    }
  }
}
```

## Services

Heimdallr provides a few helper "services" to assist with the creation \& management of applications and tokens.

### Create Application (`Heimdallr::CreateApplication`)

This service allows you to quickly create a new JWT application.

**Example**

```ruby
application = Heimdallr::CreateApplication.new(
    name: 'My Little Pony',
    scopes: %w[unicorn:create unicorn:update unicorn:hug unicorn:ride],
    algorithm: 'RS256',
    ip: request.remote_ip
  ).call
```

### Create Token (`Heimdallr::CreateToken`)

This service allows you to quickly create a new JWT token.

**Example**

```ruby
# Create a new token, but do not encode it into a JWT string
token = Heimdallr::CreateToken.new(
    application: application,
    scopes: 'unicorn:ride',
    expires_at: 1.hour.from_now,
    subject: 'Supercalifragilisticexpialidocious'
  ).call(encode: false)
```

### Decode Token (`Heimdallr::DecodeToken`)

This service is required to properly decode a JWT encoded string. Although its' primary purpose 
is for the `Authenticable` controller mixin, you are free to use it inside your application as well.

**Example**

```ruby
token = Heimdallr::DecodeToken.new('JWT-ENCODED-STRING-GOES-HERE', leeway: 30.seconds).call
```

The following actions are performed when decoding a JWT token:
- The `iss` (Application ID) \& `jti` (Token ID) claims are fetched.
- A cache hit is done to avoid a database query to see if this token was used recently.
- The signature is verified to ensure that the token was not tampered with.
- The `exp` (Expiration) claim is fetched and used to ensure that the token is still valid.
- The `nbf` (Not Before) claim is checked to see if this token is valid yet (Optional)

**Critical Issues**

This service will raise a `Heimdallr::TokenError` exception if any of the following occur:
- The `iss` or `jti` claims do not exist.
- The token does not exist in the cache or database.
- The token is malformed (Missing header, payload or signature)
- The `exp` or `nbf` claims do not match what is stored in the database (Sanity checks)

**Recoverable Issues**

Even if an exception was not raised, you must still check to ensure that the token has no errors:

```ruby
if token.token_errors?
  # TODO: Do something spectacular with the errors!
  render json: { errors: [*token.token_errors] }, status: 420
end
```

Errors can be any of the following:
- The token was revoked (Message: `This token has been revoked. Please acquire a new token and try your request again.`)
- The token is expired (Message: `The provided JWT is expired. Please acquire a new token and try your request again.`)
- The `nbf` claim is in the future (Message: `The provided JWT is not valid yet and cannot be used.`)

_Note: The reason that exceptions are not raised for these events is so expired / revoked tokens can be accessed by an administrator or displayed on a UI without a convoluted amount of error handling_

## Development

To run the local engine server:

```shell
bundle install
bundle exec rails server
```

### Testing

Run all the rspec unit tests by doing the following:

_Note: You must have a PostgreSQL server running locally before running this command!_
    
```shell
bin/rails db:create db:migrate RAILS_ENV=test
bundle exec rspec
```

### Update the README.md Table of Contents

Make sure you have doctoc installed:

```shell
npm install -g doctoc
```

Run the doctoc command in the project directory:

```shell
doctoc README.md --github
```

### Update the gem documentation

Ensure you have the yard gem installed:

```shell
gem install yard
```

Update the documentation by running the yard command in the project directory:

```shell
yard
```
