# Serving Your Site

We are going to serve a [Quarto](https://quarto.org/) site behind an OAuth proxy to make it private, as [described here](../README.md).

## Prerequisites

1. You have taken the [first tutorial](../local/README.md).

2. A custom domain that you don't mind experimenting with.  If you don't have one, you can [buy one here](https://domains.google.com). In this example, I'm using the custom domain `hamel.rsvp`.

## Render (Free)

[Render](https://render.com/) is a hosting serivce that provides a generous free tier.  We just have to learn a little bit about their YAML, but if you did the [first tutorial](../local/README.md), it will be approachable.

Render also has [Oauth2 Proxy tutorial](https://render.com/blog/password-protect-with-oauth2-proxy) which is pretty close to what we want.

### Setup

1. Create another OAuth application and save the `Client ID` and `Client Secret` as you did in the [minimal example](../local/README.md).  You can fill it out like this:

![](app_setup.png)

2. [fork this repo](https://github.com/hamelsmu/oauth-render-quarto/tree/main).

3. **Optional:** Change the content of your site by editing one of the `.qmd` files, then run `quarto render` to re-generate the content into the `_site/` folder.  **Make sure you check-in any changes, including the `_site` folder into your repo.**

4. [Click this link to deploy the app](https://dashboard.render.com/blueprints), and grant Render access to the repo you just forked.  Next, fill in values for the `OAUTH2_PROXY_CLIENT_ID` and `OAUTH2_PROXY_CLIENT_SECRET`:

![](render_blueprint.png)

5. Set up your custom domain by navigating to [your dashboard](https://dashboard.render.com/) and clicking on this project, which is named `oauth2-proxy-render` (unless you changed it). On the left hand side click `Settings`.  Under `Settings`, scroll down to the section named `Custom Domains`.  Add your domain there and follow the instructions.  Render will take care of provisioning an SSL certificate to enable `https` on your domain for you.

### Testing Your Site

Anytime your push a change to your repo, your site will rebuild.  Try misspelling your email in the `email_list.txt` file and see what happens, then try changing it back.  Builds are usually fast and take under a minute.

### How does it work?

See the [repo's README](https://github.com/hamelsmu/oauth-render-quarto).


## Next Steps

As an advanced exercise, I show how to do this [same thing on Kubernetes](../gke_k8s/README.md). That example:

- Deploys a static site on Kubernetes behind a load balancer, with the OAuth proxy
- Sets up automated SSL for `https` with Google Managed Certificates
- Deploys a separate webserver for the website to make the pattern more generalizable.

Deploying this on Kubernetes is much more complicated, but is something I wanted to play with.

**:point_right: [See Lesson 3: Deploying The OAuth2 Proxy On Kubernetes](../simple/README.md). :point_left:**