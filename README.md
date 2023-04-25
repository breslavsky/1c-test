# What we have
External system (Personio) is a common **source of truth** about employees and their roles.

System has a **REST API** endpoint [/api/employees](https://cdn.jsdelivr.net/gh/breslavsky/1c-test@v1.0.0/employees.json)

```json
[
   {
      "code":"anton.breslavskii",
      "first_name":"Anton",
      "last_name":"Breslavskii",
      "roles":[
         "account_manager",
         "client_solutions_head"
      ],
      "hire_date":"2023-01-01",
      "leave_date":null
   },
   {
      "code":"byron.fowler",
      "first_name":"Byron",
      "last_name":"Fowler",
      "roles":[
         "account_manager"
      ],
      "hire_date":"2023-05-01",
      "leave_date":null
   }
]
```

## Possible roles

| Code                  | Name in 1C            |
|-----------------------|-----------------------|
| account_manager       | AccountManager        |
| client_solutions_head | HeadOfClientSolutions |
| project_manager       | ProjectManager        |
| content_manager       | ContentManager        |
| analyst               | Analyst               |
| accounter             | Accounter             |
| finance_director      | FinanceDirector       |

## Common rules

1. If user left `leave_date` will be filled.
2. Primary key for syncing is a `code`

# What to do

Create data processor **Employees Importer** for 1C with features:

- [ ] Create users with target roles and temporary passwords.
- [ ] Sync if user data/roles were changed.
- [ ] Deactivate user if employee has been left.
- [ ] Provide log of synchronisation results and temporary passwords created users.
- [ ] Make ability to use sync as scheduled task.
- [ ] Show form to change user password after first login with temporary password.

# How to deliver

1. Code should be written only **in English.**
2. Create **fork** of this repository.
3. Write `DEPLOY.md` how to deploy solution to configuration.
4. Send link to your pull request.

# Reward

Cost of finished project is 100 EUR and ability to sign contract in EUR for 6-9 months with european company.

# Contacts

**Anton Breslavsky**

anton.breslavskii@esanum.de | https://t.me/breslavsky_anton

Team Lead of Esanum Development (Berlin)