<template>
  <div class="auth">
    <form>
      <div>
        <label>Username: <input v-model="username" type="text" name="username"></label>
      </div>
      <div>
        <label>Password: <input v-model="password" type="password" name="password"></label>
      </div>
      <button v-on:click="signin">Sign in</button>
      <button v-on:click="signup">Sign up</button>
    </form>
  </div>
</template>

<script>
import auth from '@/api/auth.js'
export default {
  name: 'Auth',
  methods: {
    signin() {
      auth.signin(this.username, this.password);
    },
    signup() {
      auth.signup(this.username, this.password);
    }
  }
}
</script>

<style scoped>
.auth {
  width: 300px;
  height: 300px;
}
</style>


