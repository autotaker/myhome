import util from  "@/api/util.js";

export default {
  async signin (username, password) {
    const response = await fetch('http://localhost:3000/auth/signin', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({username: username, password: password})
    });
    return await util.checkResponse(response);
  },
  async signup (username, password) {
    const response = await fetch('http://localhost:3000/auth/signup', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({username: username, password: password})
    });
    return await util.checkResponse(response);
  },
  async signout() {
    const response = await fetch('http://localhost:3000/auth/signout', {
      method: 'POST'
    });
    return await util.checkResponse(response);
  }
}