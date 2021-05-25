# SnowJumpCloud
Snowflake JumpCloud Integration

<!-- wp:paragraph -->
<p>Current <em>JumpCloud</em> integration automatically creates/updates user information Snowflake and allows you to login using SSO. But compared to identity providers like <em>Okta</em> and <em>Azure Active Directory</em> JumpCloud doesn't automatically assign roles to users so that they can perform authorised actions on Snowflake. This means administrator has to manually grant access to specific ROLE on Snowflake side every time they make GROUP level changes on JumpCloud side. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Below is a workaround to address this above limitation by using JumpCloud APIs and Snowflake External Functions. Before you proceed with below make sure you have completed SCIM integration provided by JumpCloud.</p>
<!-- /wp:paragraph -->

![image](https://user-images.githubusercontent.com/30681948/119483401-84223100-bd87-11eb-885a-af75536a1e59.png)
