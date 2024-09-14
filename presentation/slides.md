---
# try also 'default' to start simple
theme: apple-basic
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
background: https://cover.sli.dev
# some information about your slides, markdown enabled
title: Welcome to Slidev
info: |
  ## Slidev Starter Template
  Presentation slides for developers.

  Learn more at [Sli.dev](https://sli.dev)
# https://sli.dev/custom/highlighters.html
highlighter: shiki
# https://sli.dev/guide/drawing
drawings:
  persist: false
# enable MDC Syntax: https://sli.dev/guide/syntax#mdc-syntax
mdc: true
layout: intro-image
image: https://img.freepik.com/free-vector/hand-painted-watercolor-pastel-sky-background_23-2148902771.jpg?size=626&ext=jpg&ga=GA1.1.2116175301.1718064000&semt=sph
#image: 'https://source.unsplash.com/random/1920x1080/?animal,nature,city,technology,landscape'
---

# Be curious, not judgmental!
<h2 v-click="1" v-mark.strike-through="2" width="250px">
  Ted Lasso
</h2>
<h2 v-click="3" v-mark.strike-through="4">
 Will Whitman
</h2>
<h2 v-click="5" v-mark="6">
 Kamil Gałuszka
</h2>

# Unikernel Stories

<!--

Stress the importance of curiosity and open-mindedness.

I'm not an expert in Unikernels, but I'm curious about them. I'm not here to judge them, but to learn about them. I'm not here to convince you, but to inspire you to explore new ideas and possibilities.


-->

---
transition: fade-out
layout: statement
---

<v-clicks>

# This presentation is 2 years in making in my head.
## In 2022 I've attended my first Craft IT
## Where there was held amazing presentation by Michał Borkowski "From nothing to container - why do you need docker?"
## Which ended with my question: Why not Unikernels?



</v-clicks>


---
layout: statement
---

# So what Unikernel actually is?

# Why does this matter?

# Does this has anything to do with containers?


---
layout: image
image: /OperatingSystems.png
backgroundSize: 25em
---

<footer class="absolute bottom-0 right-0 p-2 color-black">Graphics source: https://www.theseus-os.com/Theseus/book/design/design.html</footer>


---
layout: full
---
# Operating Systems

* Monolith OS - They run all kernel components in a single address space for efficient communication but are less resilient to kernel failures. Applications interact with the kernel via system calls.
  * Linux
  * Windows
  * MacOS

* Microkernel OS - separate most kernel functions into user space processes. This structure enhances resilience by isolating kernel entities, but it reduces efficiency due to the need for Inter-Process Communication (IPC). Examples:

  * Minix
  * HarmonyOS
  * Redox

* Multikernel OS - manycore architectures by running a separate kernel instance on each core. 

  * BlueOS
  * BarellfishOS

<!-- Book Operating Systems Andrew Tanenbau 


**Monolithic OSes**, including Linux, Unix-like systems, Windows, and macOS, are prevalent. They run all kernel components in a single address space for efficient communication but are less resilient to kernel failures. Applications interact with the kernel via system calls.

**Microkernel OSes**, common in reliability-focused domains like embedded systems, separate most kernel functions into user space processes. This structure enhances resilience by isolating kernel entities, but it reduces efficiency due to the need for Inter-Process Communication (IPC). Examples:

* Minix
* HarmonyOS
* Redox

**Multikernel OSes** scale well on manycore architectures by running a separate kernel instance on each core. They may also replicate system service processes across cores to reduce contention. While they borrow from monolithic and microkernel systems, their standard shared memory abstraction can impact performance. 

-->

---
layout: fact
---

# TheseusOS honorable mention of Rust community

---
layout: image
image: /TheseusOS.png
backgroundSize: 20em
---

<footer class="absolute bottom-0 right-0 p-2 color-black">Graphics source: https://www.theseus-os.com/Theseus/book/design/design.html</footer>


---
layout: quote
---

# And the *reality* is that there are no absolute guarantees.  Ever. The "Rust is safe" is not some kind of absolute guarantee of code safety. Never has been. Anybody who believes that should probably re-take their kindergarten year, and stop believing in the Easter bunny and Santa Claus.

Linus Torvalds - 19 Sep 2022 13:42:44
<!---
Linus send Rust software engineers into kindergarten, and they started created their own toys... tfu Kernels (TheseusOS, HermitCore)
-->
---
layout: image
image: /conteinerization_plesk_infographic.png
backgroundSize: contain
---

---
layout: image
image: /Layers.png
backgroundSize: 25em 
---

---
layout: bullets
---
## The problem of layers in Linux goes depper:

- Linux kernel has grown to more than +350 syscalls today!
- Most of our cloud workloads is:
  - One application
  - One user to manage that application
- Context switching is penalty on performance
- We all know at compile time in advance based on code of the appllication number of syscalls it can make!
- We restrict syscalls in containers on kernel level, but we still have to pay the price of context switching!

<!--
And still you can forget which syscalls to actually exclude.

Example with File and permissions
-->

---
layout: bullets
---

## And then we believe CSPs that to deploy Web app:

<v-clicks>

- We build K8s clusters for running containers
- That have a control plane
- That manages VM used for nodes
- That schedule containers on those nodes
- That still run on a operating system based on ideas from 70's!
- To run web API...

</v-clicks>

---
layout: image
image: https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExdHh4cGJuM2N3Njd3cmpmc2E5aWdibzV0d2p1eWFwbzdob2xsOXJvcSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3cXmze4Y8igXdnkc3U/giphy.gif
backgroundSize: 35em 
---

Many 

---
layout: fact
---

# It takes more to know that serverless is using servers to be great Engineer

~ Soft Skills Enginering Podcast

---
layout: intro-image-right
image: https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExdnpzcXIyemZuaWZhNGVqbGc0ZTExdHpncWJ6azNzMmNla2tlOWw5byZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/elUGwgiPOdq7e/giphy.gif
backgroundSize: 25em 
---

### The Promises of Unikernels: Security, Simplicity, and Performance

* Security:
  * Small surface of attack due to minimal OS
  * Strong isolation via hypervisor
  * Unable to run remote execution attacks
* Simplicity
  * One process
  * One user
  * One binary
* Performance
  * Context switching is minimal, everything is in kernel mode
  * Very small images

---
layout: image
image: /vm-container-unikernel.svg
backgroundSize: 45em 
---
<footer class="absolute bottom-0 right-0 p-2 color-black">Graphics from  <a href="https://unikraft.org/docs/concepts">https://unikraft.org/docs/concepts</a></footer>

---
layout: image
image: /UnikernelsLayers.png
backgroundSize: 25em 
---

---
layout: two-cols
---

**1. Language-based Unikernels:**

* **Key Feature:** Tightly integrated with a specific programming language runtime and libraries. 
* **Examples:**
    * MirageOS (OCaml)
    * IncludeOS (C++)
    * HalVM (Haskell)

* **Advantages:**
    * **Smaller Image Size:** Due to only including language-specific libraries and minimal kernel.
    * **Faster Boot Time:** Reduced initialization overhead.
    * **Enhanced Security:** Language features like type safety help prevent vulnerabilities.
    * **Optimized Performance:** Leveraging language-specific runtime optimizations.

* **Disadvantages:**
    * **Limited Application Compatibility:**  Requires rewriting existing applications in the target language. 
    * **Less Mature Ecosystems:**  Fewer libraries and tools compared to general-purpose OSes.

::right::

**2. POSIX-like Unikernels:**

* **Key Feature:**  Attempt to provide some level of compatibility with existing POSIX applications, potentially requiring minor configuration changes. 
* **Examples:**
    * NanoVM (compatibility with Linux ABI)
    * Unikraft (compatibility with Linux ABI)
    * OSv (C/Java, emulates Linux ABI)

* **Advantages:**
    * **Easier Application Porting:**  Existing applications can often run with minimal modifications.
    * **Leverages Existing Software:**  Reuses parts of existing kernel code bases, benefiting from their maturity.

* **Disadvantages:**
    * **Larger Images:** Due to including POSIX libraries and potentially broader kernel functionality.
    * **Not Fully Compatible:** Not all POSIX features are supported, and compatibility issues can arise. 

<!---
  * Ling Erlang
  * ClickOS C
  * Rumprun (POSTIX compliant)
  * IncludeOS C++
 -->


---
layout: image
image: /security.png
backgroundSize: 35em 
---


<footer class="absolute bottom-0 right-0 p-2 color-black">Content thanks to Leonard Rapp, watch his presentation here: <a href="https://youtu.be/6BbZLI--eUw">https://youtu.be/6BbZLI--eUw</a></footer>

<!--
ASLR - Address space layout randomization 
-->

---
layout: image
image: /CanaryTechnique.png
backgroundSize: 20em 
---
<footer class="absolute bottom-0 right-0 p-2 color-black">Content thanks to Leonard Rapp, watch his presentation here: <a href="https://youtu.be/6BbZLI--eUw">https://youtu.be/6BbZLI--eUw</a></footer>


---
layout: fact
---

# Demo Time!


---
layout: intro-image-right
image: https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMTA4ZnN5ZmVrN3h4ZHpwMzhvajFxMHViejVqZmo5aXQ5ZTZncDB4eCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/67ThRZlYBvibtdF9JH/giphy.gif
---

# So why Unikernels aren't popular?

<v-click>
I don't know but if none knows then it's a high probability it's all about money.
</v-click>

---
layout: intro-image-right
image: /feedback.svg
---

# Thank You!

Feedback most appreciated. Scan this gorgeous QR Code now!