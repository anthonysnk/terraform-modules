## Applaudo Studios's Terraform code-styling guidelines

This document is intended to be a guide about general Terraform code styling 
conventions made by the community. It will contribute to have a clean code that 
any engineer working in Terraform projects can easily follow and maintain.


### Structuring Terraform configurations

Putting all code in a main.tf is a good idea when you are writing a small piece
of code (implementing an AWS service that doesn't have many Terraform resources 
associated with it). 

In all other cases you'd better have several files logically splitted like the 
example below, which enables a more clear way to read and understand the code. 

- **main.tf**: resources created. If there are too many resources, 
instead of having a big main.tf file, create separate resource files and group 
resources according the AWS service; e.g. put all IAM related resources in a 
file named iam.tf, etc).
- **locals.tf**: definition of the locals expressions needed.
- **variables.tf**: to define the variables needed to create a given resource.
- **outputs.tf**: to define the resource attributes we want export to be consumed
outside the scope of that configuration block. This is typically used in modules. 

It is also highly recommended the use of Terraform modules to standardize 
implementations and avoid code duplication.


### Naming conventions

- Use **snake_case** for naming resources, data sources, variables and outputs blocks.
- Do not repeat the resource type in resource block name. For example, “nat_gateway”
is not a good name for the resource block type “aws_nat_gateway”. Use descriptive 
names everytime is possible.
- Use **kebab-case** for naming the actual resources being created.
- Use **lowercase** letters while naming objects. 
- Always use singular nouns for names.
- Avoid using *‘default’* as a resource name, as it might cause confusion with 
objects created by default in every AWS account.
- Use **TitleCase** format for naming policies and roles.
- Use descriptive names for variables and outputs. Name them in a way that is 
understandable outside of the module scope.
- Use plural form when naming variables and outputs of type list.


### Code layout

- Indentation should be two spaces (not tabs).
- Attribute assignments (=) should be aligned for clarity.
- If including a count argument inside resource blocks, it has to be the first 
argument at the top and separated by a new line after it.
- Include tags argument (if supported by the resource) as the last real argument. 
It has to be followed by depends_on and lifecycle blocks when they are necessary. 
All of these should be separated by a single empty line.
- Keep the resource declarations ordered naturally by their dependencies. If `B` 
depends on `A` then `B` should come later than `A` if they are in the same file.
This makes the TF configuration read/flow more naturally.
- When defining variables, the order of the keys is: *description* , *type* and then 
the *default value*. For outputs, the order of the keys is: *description*, *value*.
- Always include a description for all variables and outputs even if you think 
it is obvious.
- Data lookups (data sources) should be declared before the resources that use them.


### General guidelines 

- Keep a consistent structure, naming and styling convention as suggested above.
- Don't hardcode values which can be passed as variables or discovered using 
data sources.
- Keep modules as plain as possible. 
- Secrets should never be checked in the repository.
- Terraform modules should contain a README.md file explaining features and how 
to use them.
- Tag all resources in a consistent way following the tagging strategy.
- **Always** run `terraform validate` and `terraform fmt` commands to make sure 
the code has no syntax errors and is properly formatted before it's pushed to 
git and reviewed by the team.

**Applaudo Studios 2021**