import Vue from 'vue'
import { firestorePlugin } from 'vuefire';
import VueObserveVisibility from 'vue-observe-visibility'
import router from './router';
import App from './App';

Vue.config.productionTip = false;

Vue.use(firestorePlugin);
Vue.use(require('vue-moment'));
Vue.use(VueObserveVisibility);

new Vue({
  render: h => h(App),
  router
}).$mount('#app');

