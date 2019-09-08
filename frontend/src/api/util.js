export default {
  async checkResponse(response) {
    let result = await response.json();
    if (response.ok) {
      return result;
    }else {
      let code = result.error;
      let reason = result.reason;
      throw Error(code + ':' + reason);
    }
  }
}