# Azure Workflow Examples
This is a tutorial/example repository documenting the process of using Azure actions in GitHub action workflows.

# Code-Signing
Using an Azure certificate in order to automatically sign code for release builds within GitHub action workflows.

## Prerequisites
1. A certificate on Azure
2. A certificate signing profile
3. Azure variables/secrets:
    1. Client ID
    2. Tenant ID
    3. Subscription ID
    4. Signing account name
    5. Certificate profile name
    6. Signing endpoint

## GitHub Setup
Repositories created before July 15th, 2026 must opt in to using immutable IDs in the subject claim:

1. On the repository, navigate to Settings -> Actions -> OIDC
2. Ensure that "Use immutable subject claim" is checked
3. Copy the "Default subject claim prefix" -- this contains the **organization's ID** and **repository ID**, in the format of `repo:Organization@OrganizationId/Repository@RepositoryId` -- you will use this in the Azure setup

Azure will match the subject claim that GitHub sends to the subject identifier on the Azure credential.  

Depending on what triggers your GitHub actions workflow it must match the setup on the Azure side. There is **one caveat**: if the trigger is on a tag with a wildcard (`v.*.*.*`, etc.) you will have to do a workaround (below), or make the trigger a static term (like `Release`).  

Please see .github/workflows for example workflow yml files!

### Working around Wildcard Tag Triggers
You can keep wildcard tags as triggers for your GitHub actions workflow by using an **environment**.  

1. On your GitHub repo under `Settings -> Environments`, create a new environment and note the name. 
2. Add your Azure secrets under #3 for prerequisites to this new environment.
3. Use this scoped environment in your GitHub actions workflow yml file. See examples.

## Azure Setup
A Federated Credential must be set up, with the following settings:

1. Federated Credential Scenario: GitHub Actions deploying Azure resources
2. Organization: (your GitHub organization name -- ex. accoes, refer to step GitHub Setup #3)
3. Organization ID: (organization's id -- refer to step GitHub Setup #3)
4. Repository: (your repository's name -- case sensitive)
5. Repository ID: (your repository's ID -- refer to step GitHub Setup #3)
6. Entity type:
    1. This must match your GitHub workflow trigger -- if your `on:` trigger is something like `push` then set Entity type to `Branch`
    2. If you use a non-wildcard tag like `Release`, set Entity type to `Tag`
7. The next field will be dependant on the Entity type, and it will be the name or term of your Entity, i.e.: your trigger is on the `Release` tag, Entity type will be `Tag` and this field will be `Release`


## Funky Self-Hosted Runner Nonsense
Self-hosted runners can come with all sorts of caveats, which I've decided to note.

1. When using any of the official Azure GitHub actions workflow steps, the self-hosted machine must have the Azure CLI installed. If it was installed while the actions-runner service was still running, it must be restarted before the `az` alias becomes available to your workflows.
2. Self-hosted runners on Windows can have issues with all sorts of stuff surrounding long filepaths -- you can enable long filepaths on Windows systems using this Powershell command (which can also be a GitHub actions workflow step)
```
Start-Process powershell -Verb RunAs -ArgumentList "-Command", "New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1 -PropertyType DWORD -Force;"
```
3. If your self-hosted runner is running an older version of Windows, the `pwsh` alias to `powershell.exe` might not be available, which is used by most of the official Azure GitHub actions workflow steps. You can add the alias as a simlink using the following command prompt command:
```
mklink C:\Windows\System32\pwsh.exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
```