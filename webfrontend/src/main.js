import Vue from 'vue'
import { firestorePlugin } from 'vuefire';
import VueObserveVisibility from 'vue-observe-visibility'
import router from './router';
import App from './App';
import firebase from 'firebase';

Vue.config.productionTip = false;

Vue.use(firestorePlugin);
Vue.use(require('vue-moment'));
Vue.use(VueObserveVisibility);

let app = '';

firebase.auth().onAuthStateChanged(() => {
  if (!app) {
    /* eslint-disable no-new */
    app = new Vue({
      router,
      render: h => h(App)
    }).$mount('#app');
  }
});
