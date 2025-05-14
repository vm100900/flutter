![239846c9-d62f-43aa-aa24-723801116a42](https://github.com/user-attachments/assets/54d9e31e-c54e-4f6a-af9b-e780664230ee)

Florism is a SDK based off of Flutter that integrates glassmorphism into Flutter, making it easy for everyone to have great UI while maintaining. All flutter widgets are reserved.
We currently have only one new widget, which is the Glassmorphic Container. The Glassmorphic container even has a bobbing feature.
Here is a example code:
<pre>
  <code>
    GlassmorphicContainer(
          bob: true,
          padding: const EdgeInsets.all(24),
          child: const Text(
            'Your glass container',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black38,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        )
  </code>
</pre>
