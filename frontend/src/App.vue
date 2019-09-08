<template>
  <div id="app">
    <nav>
      <ul class="nav-left">
        <router-link tag="li" to="/" exact>
          <a>
            <strong>MyHome</strong>
          </a>
        </router-link>
        <router-link tag="li" to="/hello" exact>
          <a>Hello</a>
        </router-link>
        <router-link tag="li" to="/dbtest" exact>
          <a>DBTest</a>
        </router-link>
      </ul>
      <ul>
        <template v-if="authenticated">
          <a>{{ username }}</a>
          <button v-on:click="signout">Signout</button>
        </template>
        <template v-else>
          <li>
            <popper trigger="click" :options="{ placement: 'left' }">
              <auth class="popper" auth-type="signin" v-on:signined="onSignin" />
              <button slot="reference">Signin</button>
            </popper>
          </li>
          <li>
            <popper trigger="click" :options="{ placement: 'left' }">
              <auth class="popper" auth-type="signup" v-on:signuped="onSignup"/>
              <button slot="reference">Signup</button>
            </popper>
          </li>
        </template>
      </ul>
    </nav>
    <notifications group="main" position="top center" />

    <router-view />
  </div>
</template>

<script>
import Auth from "@/components/Auth";
import AuthAPI from "@/api/auth.js"
import Popper from "vue-popperjs";
import "vue-popperjs/dist/vue-popper.css";
export default {
  name: "app",
  components: {
    auth: Auth,
    popper: Popper
  },
  data() {
    return { isHidden: true, authenticated: false, username: '' };
  },
  methods: {
    onSignin(authUser) {
      console.log('onSignin');
      this.username = authUser;
      this.authenticated = true;
      return;
    },
    onSignup(authUser) {
      console.log('onSignup');
    },
    async signout() {
      await AuthAPI.signout()
      this.authenticated = false;
    }
  }
};
</script>

<style>
#app {
  font-family: "Avenir", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
nav {
  background-color: #4fc08d;
}
.nav-left {
  margin-right: auto;
}
.hidden {
  display: none;
}
nav {
  display: flex;
}
nav ul {
  display: flex;
  list-style: none;
  align-items: center;
  justify-content: left;
  height: 40px;
}
nav ul li {
  padding-right: 10px;
}
nav ul li a {
  color: #fff;
  text-decoration: none;
}
</style>
