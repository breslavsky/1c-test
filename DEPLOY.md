# Deploying

1. Open an empty database 1C in **Designer**

![Designer](./img/1.png)

2. Next, select **Configuration** and select **Restore Configuration in Files**

![Restore Configuration in Files](./img/2.png)

3. Next, select the directory **src** from this project and click button **Import**

![src](./img/3.png)

4. Next, click **Update database configuration (F7)**

![Update database configuration (F7)](./img/4.png)

5. Next, click **Accept**

![Accept](./img/5.png)


# Settings

## Creating an Administrator

1. In **Designer** select **Administration** and select **Users**

![Users](./img/6.png)

2. Next, click button **Add (Ins)** and create a user

![Add (Ins)](./img/7.png)

3. For the new user, specify the **FullAccess** role and click **OK**

![FullAccess](./img/8.png)

## Setting up Synchronization

1. In subsystem Employees, click **Settings**

![Settings](./img/9.png)

2. Specify the correct settings for connecting to the REST API endpoint /api/employees

![Settings](./img/10.png)

3. To sync, click **Sync**

![Sync](./img/11.png)

4. To use sync as scheduled task, set up a **Schedule**

![Schedule](./img/12.png)


# Other

Information about sync errors is saved in the **Event log**.
Information about successful synchronization is saved in the **Log of synchronisation results**

![Log of synchronisation results](./img/13.png)