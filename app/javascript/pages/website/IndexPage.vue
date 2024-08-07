<template>
  <div>
    <div class="container-features">
      <div class="container-image">
        <img src="/portrait.jpg" alt="portrait" />
        <div class="shadow-image collab">
          <p>Shoot.</p>
          <p class="ml-3 text-lg">Select.</p>
          <p class="ml-6 mt-4 text-5xl">Shoot<strong>Select</strong></p>
        </div>
      </div>
    </div>
    <div class="collab border border-solid mt-36 grid grid-cols-2">
      <!-- <div class="grid grid-cols-2 gap-2">
        <img src="/photoshoot.webp" alt="photoshoot" />
        <img src="/wedding.webp" alt="wedding" />
        <img src="/product.webp" alt="product" />
        <img src="/headshot.webp" alt="headshot" />
      </div> -->
      <!-- <div class="grid grid-rows-2"> -->
      <div>
        <img src="/teamwork.webp" alt="headshot" class="w-full h-fit" />
      </div>
      <!-- </div> -->
      <ul class="p-16 pt-24 text-xl flex flex-col gap-4">
        <li>You had a photoshoot. Now, you need to retouch.</li>
        <li class="text-2xl">Do you:</li>
        <li>Select from <strong class="text-2xl">hundreds of photos</strong>?</li>
        <li>
          Decide in <strong class="text-2xl">collaboration</strong> with clients, photographers, art
          director, creative director, etc.?
        </li>
        <li>
          Chain yourself to a <strong class="text-2xl">big work station</strong> all day long?
        </li>
        <li>
          Prefer <strong class="text-2xl">budget</strong> or
          <strong class="text-2xl">free</strong> solutions?
        </li>
      </ul>
    </div>
    <div class="flex justify-center py-24 text-5xl">
      <div>
        <div class="text-xl">then</div>
        This is For You.
      </div>
      <!-- When moving the mouse over the text, the text should change to "ShootSelect" -->
    </div>
    <div class="simple-review grid grid-cols-2">
      <div class="flex justify-center">
        <img src="/appUI.jpg" alt="portrait" />
      </div>
      <div class="bg-white border border-solid text-black pl-16">
        <p class="mt-40 mb-8 text-4xl">Photo culling is <strong>simple</strong>.</p>
        <p class="text-2xl mb-2">All you have to do is select</p>
        <table>
          <tr v-for="opt in reviewDisplayOptions.reverse()" :key="opt.value">
            <td>
              <div class="flex items-center mb-4">
                <font-awesome-icon
                  :icon="`fa-solid fa-${opt.icon}`"
                  class="flex items-center text-2xl"
                />
              </div>
            </td>
            <td class="text-2xl pl-4">
              <div class="flex items-center">{{ opt.value }}</div>
            </td>
          </tr>
        </table>
        <div
          v-for="opt in reviewDisplayOptions.reverse()"
          :key="opt.value"
          class="flex gap-4 items-center"
        >
          <p></p>
        </div>
      </div>
    </div>
    <div class="container-features border border-solid mt-20">
      <div class="container-image">
        <img src="/photocrew.webp" alt="portrait" />
        <div class="shadow-image">
          <p class="ml-2">Shoot.</p>
          <p class="ml-6 text-lg">Select.</p>
          <p class="ml-8 mt-4 text-3xl">Shoot<strong>Select</strong></p>
        </div>
      </div>
    </div>
    <div class="container-features select border border-solid mt-20">
      <div class="container-image select">
        <img src="/select.webp" alt="portrait" />
      </div>
    </div>
    <div class="contact border border-solid">Contact us</div>
  </div>
</template>

<script setup lang="ts">
const reviewDisplayOptions = [
  { value: 'No', icon: 'xmark' },
  { value: 'Maybe', icon: 'question' },
  { value: 'Yes', icon: 'check' },
];
</script>

<style scoped>
@import '../../assets/css/base.css';

.container-features {
  display: flex;
  justify-content: center;
  width: auto;
  position: relative;
  z-index: 0;
  &.select,
  &.collab {
    background-color: white;
    color: var(--black-photobg);

    .container-image .shadow-image {
      box-shadow: none;
    }
  }

  .container-image {
    position: relative;
    height: calc(100vh - 8.5rem);
    max-height: calc(100vh - 8.5rem);
    img {
      height: 100%;
      max-height: calc(100vh - 8.5rem);
      width: auto;
      position: relative;
      z-index: 0;
      margin: 0 auto;
    }
    .shadow-image {
      position: absolute;
      top: 0;
      left: 0;
      z-index: 1;
      height: 100%;
      width: 100%;
      box-shadow: inset -20px 2px 50px 50px var(--black-photobg);
    }
  }
}
</style>
