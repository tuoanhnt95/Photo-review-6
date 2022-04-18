<p align="center">
  <a href="https://rubyonrails.org/"><img width="300" src="https://zakaria.dev/assets/images/banner/Ruby_On_Rails_Logo.png" alt="Ruby On Rails"></a>
  <a href="https://vite-ruby.netlify.app/"><img width="120" src="https://zakaria.dev/assets/images/banner/vite_ruby.svg" alt="Vite Ruby"></a>
  <a href="https://vuejs.org/"><img width="100" src="https://zakaria.dev/assets/images/banner/vuejs-logo.png" alt="Vue.js"></a>
</p>

# An example Rails 7 app

[![](https://badgen.net/badge/Rails/7.0.2.3/red)](https://github.com/zakariaf/rails-base-app/blob/main/Gemfile.lock) [![](https://badgen.net/badge/Ruby/3.1.2/red)](https://github.com/zakariaf/rails-base-app/blob/main/.ruby-version) [![](https://img.shields.io/badge/dynamic/json?color=red&label=Vite&query=%24.devDependencies.vite&url=https%3A%2F%2Fraw.githubusercontent.com%2Fzakariaf%2Frails-base-app%2Fmain%2Fpackage.json)](https://github.com/zakariaf/rails-base-app/blob/main/package.json) [![](https://img.shields.io/badge/dynamic/json?color=brightgreen&label=Vue&query=%24.dependencies.vue&url=https%3A%2F%2Fraw.githubusercontent.com%2Fzakariaf%2Frails-base-app%2Fmain%2Fpackage.json)](https://github.com/zakariaf/rails-base-app/blob/main/package.json) [![GitHub license](https://img.shields.io/github/license/zakariaf/rails-base-app)](https://github.com/zakariaf/rails-base-app/blob/main/LICENSE)

**This app is using Rails 7, Ruby 3, Vite and Vue 3** You could use this example app as a base for your new project, or as a tutorial that tells you which steps you need to start a project from scratch

This example app includes some gems that I'm using them for a long time. it wires up
a number of things you might use in a real world Rails app, but at the same time it's not
loaded up with a million personal opinions.

## Tech stack

I used `rails new baseapp -c tailwindcss -d postgresql` command to init the project to have based on importmaps and default configs, but I removed importmaps and tailwindcss and all default configs and moved to using Vite instead.
You can see the list of gems that I use in the project with the link of the related commit, so you can easily find what I configured for each gem.

### Back-end

Order by the commit I did:

1. [PostgreSQL](https://www.postgresql.org/) ([init project](https://github.com/zakariaf/rails-base-app/commit/f62b5cfab5a58aff5f233d3f05b5e5b157d5a5c9))
2. [RSpec](https://github.com/rspec/rspec-metagem) ([commit1](https://github.com/zakariaf/rails-base-app/commit/9363d5196130661481ebad2f4067f88b5558ed8e)) ([commit2](https://github.com/zakariaf/rails-base-app/commit/98b97191858a41055c624a9668627a63efa2393f))
3. [Factory Bot Rails](https://github.com/thoughtbot/factory_bot_rails) ([commit](https://github.com/zakariaf/rails-base-app/commit/6345a47aab301abf731678bc70a29af67c8d6d64))
4. [Faker](https://github.com/faker-ruby/faker) ([commit](https://github.com/zakariaf/rails-base-app/commit/436743fccee0e9f2d72a2af556dcb2bccea0d44e))
5. [Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner) ([commit](https://github.com/zakariaf/rails-base-app/commit/653e37e65260ad1b28f699d08ddf206054800810))
6. [SimpleCov](https://github.com/simplecov-ruby/simplecov) ([commit](https://github.com/zakariaf/rails-base-app/commit/a1e629b26bf45f008d27ca4ae1a794de65581e2c))
7. Rubocop(Check the **Healthy app/Backend** part)
8. [Annotate](https://github.com/ctran/annotate_models) ([commit](https://github.com/zakariaf/rails-base-app/commit/5c2a5d2480bbfdd7afd148fc08dc02bda324fc0e))
9. [Pry](https://github.com/pry/pry) ([commit](https://github.com/zakariaf/rails-base-app/commit/fd94d91fda2e28293266b3f210801e8462fad4cb))
10. [Pagy](https://github.com/ddnexus/pagy) ([commit1](https://github.com/zakariaf/rails-base-app/commit/f5c4839ba05fe8a927bb18e06e89b0fb20f12045)) ([commit2](https://github.com/zakariaf/rails-base-app/commit/090194eb6912a72ec23349afbca1d3e211204769))
11. [HasScope](https://github.com/heartcombo/has_scope) ([commit](https://github.com/zakariaf/rails-base-app/commit/a1564e9f8ee645b5b6394bc99608d57eef95b830))
12. [JSON:API serializer](https://github.com/jsonapi-serializer/jsonapi-serializer) A fast JSON:API serializer for Ruby Objects ([commit](https://github.com/zakariaf/rails-base-app/commit/c57cb9db2c0df761e48bdae77971d5fd093033bb)) and [jsonapi.rb](https://github.com/stas/jsonapi.rb) which provide some features for `jsonapi-serializer` [PR](https://github.com/zakariaf/rails-base-app/pull/9)
13. [Action Cable](https://guides.rubyonrails.org/action_cable_overview.html) ([commit](https://github.com/zakariaf/rails-base-app/commit/3d6bd4194c3a992c838093bb8c8c7332784cffba))
14. [Redis](https://redis.io/) ([commit](https://github.com/zakariaf/rails-base-app/commit/3d6bd4194c3a992c838093bb8c8c7332784cffba))
15. [Sidekiq](https://github.com/mperham/sidekiq) ([commit](https://github.com/zakariaf/rails-base-app/commit/f7b759d9d42ce3444a04978fe2cbfc66cd120250))
16. [dotenv](https://github.com/bkeepers/dotenv) ([commit](https://github.com/zakariaf/rails-base-app/commit/3aaa696c4228aac2dac40ff42591f07dc74a62bb))

### Front-end

17. [Vite](https://github.com/ElMassimo/vite_ruby) Removing importmaps and all frontend libraries and Use Vite instead ([PR](https://github.com/zakariaf/rails-base-app/pull/1))
18. Code quality and format (Check **Healthy app/Frontend** part)
19. [Vue.js](https://vuejs.org/) Vue.js version 3 ([PR](https://github.com/zakariaf/rails-base-app/pull/4))

### Healthy app

#### Frontend

- Code quality and format ([PR1](https://github.com/zakariaf/rails-base-app/pull/2), [PR2](https://github.com/zakariaf/rails-base-app/pull/3))
  - [ESlint](https://eslint.org/)
  - [Eslint plugin vue](https://eslint.vuejs.org/rules/)
  - [Prettier](https://prettier.io/)
  - [Husky](https://typicode.github.io/husky/#/)
  - [lint-staged](https://github.com/okonet/lint-staged)

#### Backend

- [RuboCop](https://github.com/rubocop/rubocop) Code quality and format. First I added [rubocop-rails_config gem](https://github.com/toshimaru/rubocop-rails_config) by these two commits ([commit1](https://github.com/zakariaf/rails-base-app/commit/abfdce196721e517b9391b618093506fe062c499)) ([commit2](https://github.com/zakariaf/rails-base-app/commit/89e675b793a0467b271e91c85215a6539bcc4b57)), but after a while, I removed this gem and added rubocop gem and its extensions separately in this [PR](https://github.com/zakariaf/rails-base-app/pull/8)

20. [Brakeman](https://github.com/presidentbeef/brakeman) Checking Ruby on Rails applications for security vulnerabilities. you can check `config/brakeman.ignore` to see ignore errors ([PR](https://github.com/zakariaf/rails-base-app/pull/7))
21. [bundler-audit](https://github.com/rubysec/bundler-audit) Patch-level verification for bundler ([PR](https://github.com/zakariaf/rails-base-app/pull/7))
22. [Fasterer](https://github.com/DamirSvrtan/fasterer) Make Rubies code faster by suggestion some speed improvements. check `.fasterer.yml` to enable/disable suggestions ([PR](https://github.com/zakariaf/rails-base-app/pull/7))
23. [License Finder](https://github.com/pivotal/LicenseFinder) Check the licenses of the gems and packages. you can update `doc/dependency_decisions.yml` to manage licenses ([PR](https://github.com/zakariaf/rails-base-app/pull/7))

#### Common

24. [overcommit](https://github.com/sds/overcommit) to manage and configure Git hooks by managing all healthy app tools. you can check `.overcommit.yml` to enable or disable tools. ([PR](https://github.com/zakariaf/rails-base-app/pull/7))
25. Enabling github action to run `overcommit` after push and pull requests in github. Check `.github/workflows/lint.yml` to see the github configs ([PR](https://github.com/zakariaf/rails-base-app/pull/7))

## Apps

I always prefer to have two apps for my projects, one for the part that will be shown public (I called it **Website**), and the second one for the part that you are managing there (I called it **Panel**), simplify you need to log in to have access there.

If you can check the codes you can see that there are two layout view files and two actions in application_controller, and two routes in routes.rb file. and for frontend there are two different entrypoints and routers ane etc.

In this case, you can use different technologies and UI Component Libraries in frontend, e.g. use [Vuetify](https://vuetifyjs.com/en/) for **Website** and use [VueTailwind](https://www.vue-tailwind.com/) for **Panel**. or even (it's a bit headache) but you can use [React](https://reactjs.org/) for **Website** and use [Vue.js](https://vuejs.org/) for **Panel**.

Two simple html/css templates have been added for **Website** and **Panel**. you can remove them easily

![Website and Panel preview](https://zakaria.dev/repos_images/website.png)

## Running this app

You need to do few small steps to run the app

### Clone the repo

```sh
git clone https://github.com/zakariaf/rails-base-app baseapp
cd baseapp
```

### Copy example file

```sh
cp .env.example .env
```

Environment variables defined here(`.env`), feel free to change or add variables as needed.
This file is ignored from git (Check `.gitignore`) so it will never be commit.

If you use different values for environment variables in other envs, e.g. **test**, you need to copy one more: `.env.test`

### Setup the project

create databases

```sh
rails db:setup
```

### start the project

- rails server

  ```sh
  rails s
  ```

- frontend app

  ```sh
  yarn dev
  ```

## Renaming the project

This app is named `baseapp` and the module is named `BaseApp`. But for sure you would like to have a different name.

The only thing you need to do is just running the `bin/rename-project yourappname YouAppName` script.
as you see this script needs 2 arguments:

- First argument: The lower case version of your app's name, such as `myapp` or `my_app` depending on your preference.
- First argument: Used for your app's module name. such as `MyApp`

`bin/rename-project myapp MyApp`

This script is going to:

- Perform a number of find / replace actions
- Initialize a new git repo for you (Optionally)

After that, If you're happy with your new project's name you can delete this
script.

Or you can keep it around in case you decide to change your project's
name later on.

I got the rename script idea and codes from [Docker Rails Example](https://github.com/nickjj/docker-rails-example#running-a-script-to-automate-renaming-the-project) project with some small changes.

## TODO

- [ ] Add a JWT authentication solution
- [ ] Add cypress
- [ ] Dockerize
- [ ] automatic deploy process using capistrano
- [ ] add .gitlab-ci
