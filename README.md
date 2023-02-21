# Make Static Sites Private With OAuth For Free

> Like GitHub Pages, but you choose who can see it without usernames & passwords

Do you want to serve a static site semi-privately so only specific users can see it?  For example, you may want to host private docs or offer a paid course.  There are many complicated solutions that involve building a login flow and maintaining a database of usernames/passwords.  Thankfully, there is a much easier way with [Oauth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/docs/).

Concretely, this tutorial shows how to use the Oauth2 Proxy to make a static site private with minimal dependencies and secure it with an email whitelist (a [text file with emails](./emails/email_list.txt)). There are many other authorization schemes in addition to an email whitelist, [which you can read about here](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview).

[This section](#how-does-this-work) describes how OAuth works in the context of this tutorial.

# Tutorial

This tutorial has three parts that become progressively complex depending on your goals. However, you can stop at any lesson once you are satisfied.

Prerequisites: knowledge of Docker and familiarity with hosting static sites (like on GitHub Pages).

1. **[Running OAuth Locally](./local/README.md):** this runs a minimal static site locally, secured with the OAuth2 Proxy.  This allows you to gain an intuition of how things work before proceeding to the next step.

2. **[Serve The Private Site (For Free!)](./simple/README.md):** You will host the same site you created locally **for free!**  You will also learn how to set up SSL for `https` with a custom domain.

3. **(Optional) [Hosting on Kubernetes](./gke_k8s/README.md)**: Finally, you will deploy a website secured by OAuth on Kubernetes.  This assumes some experience with Kubernetes.

# FAQ

1. **Is this only for static sites?**  No! You can put applications behind the proxy too. See [this explanation](./local/README.md#is-this-only-for-static-sites).

2. **Does GitHub Pages have something like this?**: Only if you [purchase GitHub Enterprise Cloud](https://docs.github.com/en/enterprise-cloud@latest/pages/getting-started-with-github-pages/changing-the-visibility-of-your-github-pages-site) which is absurdly expensive if you want it solely for the purposes of securing a static site (> $100/month for just 5 users!).

3. **Can't you do this with [Netlify](https://www.netlify.com/)?**: To do something similar on Netlify, you have to use [invite-only private sites](https://docs.netlify.com/visitor-access/identity/registration-login/#set-registration-preferences), which triggers [identity pricing](https://www.netlify.com/pricing/#add-ons-identity), which means that **you need to pay over $99 per month if you have over 5 Active users!** That is ridiculous.

## How does this work?

With regards to security, [OAuth](https://oauth.net/) is often used for **[authentication](https://www.okta.com/identity-101/authentication-vs-authorization/)**[^1], or identifying who you are.  You may have seen sites that have you sign in with GitHub, Google, etc. These [OAuth providers](https://en.wikipedia.org/wiki/List_of_OAuth_providers) pass your identity (and other information if you consent) to the site you are trying to access.  In our case, we just want to verify a user's email address so we can determine if they are allowed to see our site.  

There is another step in the security flow referred to as **[authorization](https://www.okta.com/identity-101/authentication-vs-authorization/#:~:text=Authorization%20in%20system%20security%20is,access%20control%20or%20client%20privilege.)** which only shows content the verified user is allowed to see (which is typically implemented in your website's code).  Thankfully, [Oauth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/docs/) offers many ways of **authorization** that's built-in. This is nice as it doesn't force you to change your website's code (like adding login forms, conditional logic, etc).

A common reason for using OAuth for authentication is to save users from creating an additional username/password for a site.

[^1]: OAuth may be used for more than authentication.  OAuth allows a user to grant third parties access to query data or interact with APIs relevant to the OAuth provider.  For example, when a user signs into your website with GitHub, OAuth gives your app (which is the OAuth2-proxy) a token with a scope (permission level) that the user consents to.  In this example, this is what the consent screen looks like, which indicates that the app wishes to get your email: <p><img src="https://user-images.githubusercontent.com/1483922/219905220-ad7cb3c2-d51f-4588-a813-db12da318fbf.png" align="center" height="300" width="300" ></p> You can set [other scopes](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps) for the OAuth application.  In our case, we only want to verify the user's email address so we set the scope to `user:email` with the argument `--scope user:email`.
