using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SpaceShip : MonoBehaviour
{
    public Vector3 velocity;
    ParticleSystem exhaust;

    public Text[] jumpText;
    public Text[] speedText;
    public Text velocityText;
    public Text positionText;

    public Text oxygenText;
    public Text shieldsText;
    public Text powerText;
    public Text temperatureText;
    public Text ammoText;

    public GameObject roundPrefad;

    public GameObject jumpSphere;
    public GameObject shield;

    readonly float rotSpeed = 100;
    bool rotating = false;

    public enum Mode {Reset, Attack, Defense, Stealth}
    public Mode mode;

    LifeSupport ls;
    Weapons weapons;

    // Start is called before the first frame update
    void Start()
    {
        ls = new LifeSupport();
        weapons = new Weapons();

        exhaust = this.GetComponentInChildren<ParticleSystem>();
        var particleEmission = exhaust.emission;
        particleEmission.enabled = false;

        shield.SetActive(false);
        jumpSphere.transform.localScale = Vector3.zero;
    }

    // Update is called once per frame
    void Update()
    {
        UpdateRotation();
        if (!rotating)
        {
            UpdatePosition();
        }
        else
        {
            var particleEmission = exhaust.emission;
            particleEmission.enabled = false;
        }
    }

    public void UpdateVelocity()
    {

        try
        {
            Vector3 newV = new Vector3(float.Parse(speedText[0].text), float.Parse(speedText[1].text), float.Parse(speedText[2].text));
            velocity = newV;
        }
        catch(Exception)
        {
            velocity = Vector3.zero;
        }

        velocityText.text = "Velocity: (" + velocity.x + "," + velocity.y + "," + velocity.z + ")";
    }

    void UpdatePosition()
    {
        positionText.text = "Position: (" + transform.position.x + "," + transform.position.y + "," + transform.position.z + ")";
        transform.position = transform.position + velocity * Time.deltaTime;
        
        //turn thrust effect on only when moving
        var particleEmission = exhaust.emission;
        if (velocity != Vector3.zero)
            particleEmission.enabled = true;
        else if (velocity == Vector3.zero)
            particleEmission.enabled = false;

    }


    void UpdateRotation()
    {
        //rotate ship to be facing same direction as velocity
        Quaternion toRotation = Quaternion.LookRotation(velocity.Equals(Vector3.zero) ? Vector3.forward : velocity);
        var step = rotSpeed * Time.deltaTime;
        transform.rotation = Quaternion.RotateTowards(transform.rotation, toRotation, step);
        if (transform.rotation != toRotation)
            rotating = true;
        else
            rotating = false;
    }

    float rate = .5f;
    public IEnumerator JumpUp(Vector3 newPos)
    {
        float t = 0;
        while (t < 1)
        {
            t += Time.deltaTime * rate;
            jumpSphere.transform.localScale = Vector3.one * Mathf.Lerp(0, 2, t);
            yield return null;
        }
        transform.position = newPos;
        StartCoroutine(JumpDown());
    }

    public IEnumerator JumpDown()
    {
        float t = 1;
        while (t > 0)
        {
            t -= Time.deltaTime * rate;
            jumpSphere.transform.localScale = Vector3.one * Mathf.Lerp(0, 2, t);
            yield return null;
        }
        jumpSphere.transform.localScale = Vector3.zero;
    }

    void Jump()
    {
        try
        {
            Vector3 newPos = new Vector3(float.Parse(jumpText[0].text), float.Parse(jumpText[1].text), float.Parse(jumpText[2].text));
            StartCoroutine(JumpUp(newPos));
        }
        catch (Exception)
        {
            
        }
    }
    public void Fire()
    {
        GameObject round = GameObject.Instantiate(roundPrefad);
        Rigidbody rb = round.GetComponentInChildren<Rigidbody>();
        rb.velocity = velocity + transform.forward * 10;

        //TODO
        
    }

    IEnumerator BlipShield()
    {
        float t = 0;
        while (t < .1)
        {
            t += Time.deltaTime;
            yield return null;
        }
        shield.SetActive(false);
        while (t < .2)
        {
            t += Time.deltaTime;
            yield return null;
        }
        shield.SetActive(true);
        while (t < .3)
        {
            t += Time.deltaTime;
            yield return null;
        }
        shield.SetActive(false);
    }

    public void Hit()
    {
        //TODO
        shield.SetActive(true);
        StartCoroutine(BlipShield());
    }


}
