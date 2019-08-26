<template>
  <div id="app">

    <nav>
      <ul class="nav-left">
        <router-link tag="li" to="/" exact> <a><strong>MyHome</strong></a></router-link>
        <router-link tag="li" to="/hello" exact> <a>Hello</a></router-link>
        <router-link tag="li" to="/dbtest" exact> <a>DBTest</a></router-link>
      </ul>
      <ul>
        <li><a v-on:click="showSignin">Signin</a></li>
        <li><a v-on:click="showSignup">Signup</a></li>
      </ul>
    </nav>
    
    <auth v-bind:class="{ hidden: isHidden }" v-bind:auth-type="authType" />
    
    <router-view/>
  </div>
</template>

<script>
import Auth from '@/components/Auth'
export default {
  name: 'app',
  components: {
    'auth': Auth
  },
  data() {
    return { 'isHidden': true,
             authType: 'signin' }
  },
  methods: {
    showSignin () {
      this.isHidden = false;
      this.authType = 'signin';
    },
    showSignup () {
      this.isHidden = false;
      this.authType = 'signup'
    }
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
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
